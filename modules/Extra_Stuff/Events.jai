// event containers
// features we want
// event emitters cn broadcast eevnts without giving a shit who (if anyone) is listening
// things can listen for events

#import "Graphics";

#scope_export   // PUBLIC STRUCTS

EventQueue :: struct {
    events : [EVENT_LISTENER_MAX_EVENT_COUNT] EventInfo;
    count : u8;
};

EventType :: enum u8 { //correlates to index in dispatch registry?
    NONE         :: 0;
    CAMERA_MOVE     :: 1;
    CAMERA_ROTATE   :: 2;
};
// system events could use upper range (128-255) and local event systems use lower range, potentially, or vice versa

EventPriority :: enum u8 {
    LOW     :: 0;
    MEDIUM  :: 1;
    HIGH    :: 2;
};

EventInfo :: struct {
    sender              : string;      // who sent this                                    
    data                : *void;       // any data related to the event                    --- pointer (8)
    sent_at_time_ms     : u32;       // probably good to know when it was sent           --- float   (4)
    respond_at_time_ms  : u32;       // useful for delays - often will be 0, or -1       --- float   (4)
    priority            : EventPriority;          // queue                                            --- u8      (1)
    type                : EventType;   // input event, engine event, gameplay event, etc   --- u8      (1)
};

#scope_file     // PRIVATE STRUCTS

#scope_file

EVENT_TYPE_COUNT :: #run type_info(EventType).(*Type_Info_Enum).values.count;
EVENT_REGISTRY_MAX_LISTENER_COUNT   :: 4;
EVENT_LISTENER_MAX_EVENT_COUNT      :: 4;

event_registry : [EVENT_TYPE_COUNT][EVENT_REGISTRY_MAX_LISTENER_COUNT] *EventQueue;
event_registry_counts : [EVENT_TYPE_COUNT] u8;

#scope_export

ListenForEventType :: (event_queue : *EventQueue, event_type : EventType) {
    print("before: %\n", event_registry);
    if event_registry_counts[event_type] < EVENT_REGISTRY_MAX_LISTENER_COUNT {
        event_registry[event_type][event_registry_counts[event_type]] = event_queue;
        event_registry_counts[event_type] += 1;
    } else {
        print("Could not add event listener to type: % - listener list is full\n", event_type);
    }
    print("after: %\n", event_registry);
}

NotifyEvent :: (event_type : EventType, event_data : *void = null, event_priority : EventPriority = .MEDIUM, event_delay_ms : u32 = 0) {
    if event_registry_counts[event_type] > 1 {
        print("No listeners for that event type: %\n", event_type);
        return;
    }

    // construct EventInfo and send it to responders
    current_time := GetTimeMilliseconds();
    event_info : EventInfo;
    {
        using event_info;
        type = event_type;
        sender = ""; // idk
        sent_at_time_ms = current_time;
        respond_at_time_ms = ifx event_delay_ms > 0 then current_time + event_delay_ms else 0;
        priority = event_priority;
        data = event_data;
    }

    // dispatch to all listeners
    for i : 0..event_registry_counts[event_type]-1 {
        listener := event_registry[event_type][i];
        SendEventToQueue(listener, event_info);
    }
}

PollEvents :: (using event_queue : *EventQueue, event : *EventInfo) -> ok : bool {
    if count < 1 return false;
    current_time := GetTimeMilliseconds();
    if events[0].type != .NONE && events[0].respond_at_time_ms < current_time {
        heap : [] EventInfo = .{count, events.data};
        element := HeapPop(*heap, CompareEvents);
        memcpy(event, element, size_of(EventInfo));
        count -= 1; // shouldnt need this...
        return true;
    }
    return false;
}

#scope_file

SendEventToQueue :: (listener : *EventQueue, event_info : EventInfo) {
    using listener;
    print("SEND EVENT listener: %, ---- event_info: %\n", listener, event_info);
    if count < EVENT_LISTENER_MAX_EVENT_COUNT {
        // currently cant pass the pointer for the actual count we use... AHHH
        heap : [] EventInfo = .{ count, events.data };
        HeapAdd(*heap, CompareEvents, *event_info);
        count += 1; // shouldnt need this..
    } else {
        print("Could not add event to queue: % - event list is full\n", event_info.type);
    }
}

// comparison function for the max heap
CompareEvents :: (a : *EventInfo, b : *EventInfo) -> result : int {
    // a-b
    // respond_at_time_ms is first
    diff : int;

    // lowest respond time - switch b and a
    diff = b.respond_at_time_ms - a.respond_at_time_ms;
    if diff != 0 return clamp(diff, -1, 1);

    // highest pri
    diff = a.priority.(int) - b.priority.(int);
    if diff != 0 return clamp(diff, -1, 1);

    // lowest sent time
    diff = b.sent_at_time_ms - a.respond_at_time_ms;
    if diff != 0 return clamp(diff, -1, 1);

    return 0;   // they're equal
}

// receivers handle the event
// ideally this would proably be async
/*
ProcessEvents :: () {
    while true {
        if next_event respond_at_time_ms > current_time break;

        next_event = pop
        if next_event.type == {

        };
}
*/
