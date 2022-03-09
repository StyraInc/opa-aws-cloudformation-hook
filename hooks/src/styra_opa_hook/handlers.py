"""Handlers for delegating AWS Cloudformation hooks to OPA"""

import logging
from typing import Any, MutableMapping, Optional

import requests

from cloudformation_cli_python_lib import (
    BaseHookHandlerRequest,
    Hook,
    HookInvocationPoint,
    OperationStatus,
    ProgressEvent,
    SessionProxy,
)

from .models import HookHandlerRequest, TypeConfigurationModel

# Use this logger to forward log messages to CloudWatch Logs.
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.INFO)

TYPE_NAME = "Styra::OPA::Hook"

hook = Hook(TYPE_NAME, TypeConfigurationModel)
test_entrypoint = hook.test_entrypoint

def opa_query(request: HookHandlerRequest, action: str, url: str) -> ProgressEvent:
    """Query OPA and return a ProgressEvent based on the decision"""

    progress: ProgressEvent = ProgressEvent(
        status=OperationStatus.IN_PROGRESS
    )

    opa_input = {
        "input": {
            "action": action,
            "hook": request.hookContext.hookTypeName,
            "resource": {
                "id": request.hookContext.targetLogicalId,
                "name": request.hookContext.targetName,
                "type": request.hookContext.targetType,
                "properties": request.hookContext.targetModel.get("resourceProperties")
            }
        }
    }

    try:
        resp = requests.post(url, json=opa_input)
    except requests.ConnectionError:
        LOG.error("Failed connecting to OPA at %s", url)
        return OperationStatus.FAILED

    if resp.status_code == 200:
        body = resp.json()
        if not "result" in body:
            LOG.error("OPA returned empty/undefined result")
            progress.status = OperationStatus.FAILED
        else:
            result = body["result"]
            if len(result) == 0:
                # deny style rule, so empty result == success
                progress.status = OperationStatus.SUCCESS
            else:
                message = " | ".join(result)
                LOG.info("OPA denied the request with message: %s", message)
                progress.status = OperationStatus.FAILED
                progress.message = message

    else:
        LOG.error("OPA returned status code: %d", resp.status_code)
        LOG.error(resp.json())
        progress.status = OperationStatus.FAILED

    return progress

# pylint: disable=unused-argument,missing-function-docstring
@hook.handler(HookInvocationPoint.CREATE_PRE_PROVISION)
def pre_create_handler(
        session: Optional[SessionProxy],
        request: HookHandlerRequest,
        callback_context: MutableMapping[str, Any],
        type_configuration: TypeConfigurationModel
) -> ProgressEvent:

    LOG.info("Hook triggered for target %s %s", request.hookContext.targetName, request.hookContext.targetLogicalId)

    return opa_query(request, "create", type_configuration.OpaUrl)

# pylint: disable=unused-argument,missing-function-docstring
@hook.handler(HookInvocationPoint.UPDATE_PRE_PROVISION)
def pre_update_handler(
        session: Optional[SessionProxy],
        request: BaseHookHandlerRequest,
        callback_context: MutableMapping[str, Any],
        type_configuration: TypeConfigurationModel
) -> ProgressEvent:

    LOG.info("Hook triggered for target %s %s", request.hookContext.targetName, request.hookContext.targetLogicalId)

    return opa_query(request, "update", type_configuration.OpaUrl)

# pylint: disable=unused-argument,missing-function-docstring
@hook.handler(HookInvocationPoint.DELETE_PRE_PROVISION)
def pre_delete_handler(
        session: Optional[SessionProxy],
        request: BaseHookHandlerRequest,
        callback_context: MutableMapping[str, Any],
        type_configuration: TypeConfigurationModel
) -> ProgressEvent:

    LOG.info("Hook triggered for target %s %s", request.hookContext.targetName, request.hookContext.targetLogicalId)

    return opa_query(request, "delete", type_configuration.OpaUrl)
