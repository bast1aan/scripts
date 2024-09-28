from typing import NamedTuple

import dbus


def authorize(message: str) -> bool:

    class PolkitAuthorizationResult(NamedTuple):
        is_authorized: dbus.Boolean
        is_challenge: dbus.Boolean
        details: dbus.Dictionary

    bus = dbus.SystemBus()

    proxy = bus.get_object('org.freedesktop.PolicyKit1', '/org/freedesktop/PolicyKit1/Authority')
    authority = dbus.Interface(proxy, dbus_interface='org.freedesktop.PolicyKit1.Authority')
    system_bus_name = bus.get_unique_name()

    subject = ('system-bus-name', {'name': system_bus_name})
    action_id = 'net.welmers.bast1aan.polkit-sshaskpass'
    details = {'message': message}
    flags = 1  # AllowUserInteraction flag
    cancellation_id = ''  # No cancellation id

    result = PolkitAuthorizationResult(
        *authority.CheckAuthorization(subject, action_id, details, flags, cancellation_id)
    )
    return bool(result.is_authorized)

