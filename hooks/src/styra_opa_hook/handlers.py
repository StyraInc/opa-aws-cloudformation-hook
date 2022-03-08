import logging
from typing import Any, MutableMapping, Optional

import requests

from cloudformation_cli_python_lib import (
    BaseHookHandlerRequest,
    HandlerErrorCode,
    Hook,
    HookInvocationPoint,
    OperationStatus,
    ProgressEvent,
    SessionProxy,
    exceptions,
)

from .models import HookHandlerRequest, TypeConfigurationModel

# Use this logger to forward log messages to CloudWatch Logs.
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.INFO)

TYPE_NAME = "Styra::OPA::Hook"

hook = Hook(TYPE_NAME, TypeConfigurationModel)
test_entrypoint = hook.test_entrypoint


@hook.handler(HookInvocationPoint.CREATE_PRE_PROVISION)
def pre_create_handler(
        session: Optional[SessionProxy],
        request: HookHandlerRequest,
        callback_context: MutableMapping[str, Any],
        type_configuration: TypeConfigurationModel
) -> ProgressEvent:
    target_model = request.hookContext.targetModel
    progress: ProgressEvent = ProgressEvent(
        status=OperationStatus.IN_PROGRESS
    )

    LOG.info("Internal testing hook triggered for target: " + request.hookContext.targetName)

    resource_properties = target_model.get("resourceProperties")
    LOG.info(resource_properties)

    r = requests.post(type_configuration.OpaUrl, json={input: resource_properties})

    if r.status_code == 200:
        LOG.info("Response status == 200")
        LOG.info(r.json())
    else:
        LOG.error("Error:" + r.status_code)
        LOG.info(r.json())
    try:
        if isinstance(session, SessionProxy):
            client = session.client("s3")

        progress.status = OperationStatus.FAILED

    except TypeError as e:
        raise exceptions.InternalFailure(f"was not expecting type {e}")

    return progress


@hook.handler(HookInvocationPoint.UPDATE_PRE_PROVISION)
def pre_update_handler(
        session: Optional[SessionProxy],
        request: BaseHookHandlerRequest,
        callback_context: MutableMapping[str, Any],
        type_configuration: TypeConfigurationModel
) -> ProgressEvent:
    target_model = request.hookContext.targetModel
    progress: ProgressEvent = ProgressEvent(
        status=OperationStatus.IN_PROGRESS
    )
    # TODO: put code here

    # Example:
    try:
        # A Hook that does not allow a resource's encryption algorithm to be modified

        # Reading the Resource Hook's target current properties and previous properties
        resource_properties = target_model.get("resourceProperties")
        previous_properties = target_model.get("previousResourceProperties")

        if resource_properties.get("encryptionAlgorithm") != previous_properties.get("encryptionAlgorithm"):
            progress.status = OperationStatus.FAILED
            progress.message = "Encryption algorithm can not be changed"
        else:
            progress.status = OperationStatus.SUCCESS
    except TypeError as e:
        progress = ProgressEvent.failed(HandlerErrorCode.InternalFailure, f"was not expecting type {e}")

    return progress


@hook.handler(HookInvocationPoint.DELETE_PRE_PROVISION)
def pre_delete_handler(
        session: Optional[SessionProxy],
        request: BaseHookHandlerRequest,
        callback_context: MutableMapping[str, Any],
        type_configuration: TypeConfigurationModel
) -> ProgressEvent:
    # TODO: put code here
    return ProgressEvent(
        status=OperationStatus.SUCCESS
    )
