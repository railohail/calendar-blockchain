pragma solidity >=0.5.16;

contract MyContract {
    struct Event {
        string activity;
        uint256 date;
        string className;
    }

    Event[] public events;

    function addEvent(string memory _activity, uint256 _date, string memory _className) public {
        events.push(Event(_activity, _date, _className));
    }

    function editEvent(uint256 _index, string memory _activity, uint256 _date, string memory _className) public {
        require(_index < events.length, "Invalid event index");
        Event storage eventItem = events[_index];
        eventItem.activity = _activity;
        eventItem.date = _date;
        eventItem.className = _className;
    }

    function deleteEvent(uint256 _index) public {
        require(_index < events.length, "Invalid event index");
        for (uint256 i = _index; i < events.length - 1; i++) {
            events[i] = events[i + 1];
        }
        events.pop();
    }

    function getEventsCount() public view returns (uint256) {
        return events.length;
    }

    function getEvent(uint256 _index) public view returns (string memory, uint256, string memory) {
        require(_index < events.length, "Invalid event index");
        Event memory eventItem = events[_index];
        return (eventItem.activity, eventItem.date, eventItem.className);
    }
}
