import pytest
from rasa_sdk import Tracker
from rasa_sdk.executor import CollectingDispatcher

from actions.actions import ActionHelloWorld


def test_action_hello_world():
    """Test the hello world action."""
    action = ActionHelloWorld()
    dispatcher = CollectingDispatcher()
    tracker = Tracker("test_sender", {}, {}, [], False, None, {}, "test")
    
    result = action.run(dispatcher, tracker, {})
    
    assert result == []
    assert len(dispatcher.messages) == 1
    assert dispatcher.messages[0]["text"] == "Hello World!"