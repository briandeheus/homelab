import os
import requests
import logging
from lib.context import Context

log = logging.getLogger(__name__)
_context = Context()


class MessagePlatformException(Exception):

    def __init__(self, message):
        self.message = message


class MessagePlatform:

    def __init__(self, **kwargs):
        pass

    def send(self, text: str) -> None:
        raise NotImplementedError()


class DiscordPlatform(MessagePlatform):
    webhook_url: str = None
    username: str = "Homelab"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.webhook_url = os.environ.get("DISCORD_WEBHOOK_URL")

        if not self.webhook_url:
            raise EnvironmentError("DISCORD_WEBHOOK_URL is not set")

        self.username = os.environ.get("DISCORD_USERNAME", kwargs.get("username", DiscordPlatform.username))

    def send(self, text: str):
        data = {
            "content": text,
            "username": self.username
        }
        response = requests.post(self.webhook_url, json=data)
        try:
            response.raise_for_status()
        except Exception as e:
            log.error("Failed to send message via Discord: %s", response.text)
            raise MessagePlatformException(message=f"Failed to send message via Discord: {e}")


def send(text: str):
    if not _context.platform:
        log.warning("No messaging platform has been setup")

    _context.platform.send(text)


def setup(platform: str, **kwargs):
    if not platform:
        log.warning("No messaging platform setup. Messages such notifications will not be sent.")
        return

    if platform == "discord":
        _context.platform = DiscordPlatform(**kwargs)
