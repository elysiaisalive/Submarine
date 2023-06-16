function event_handler() {
	static s_Class = new cEventHandler();
	return s_Class;
}

/* 
    Credit to SamSpadeDev from the GameMaker Forums for inspiring the implementation
    
    USAGE : call - > instance_create_depth( 0, 0, 0, obj_eventhandler ); to instance the event handler somewhere at the very beginning of the game.
	
	Events can be called on both instances AND structs, provided you input the correct id/reference
*/

/// @desc Event Handler Constructor
function cEventHandler() constructor {
    event_struct = {};

	/// @func						Subscribe( _id, _event_id, _callback )
	/// @desc						Will subscribe an instance or struct to a specified event and store its ID and callback.
	/// @arg {Struct OR {Id} _id	The instance ID or struct that will be subscribed to this event.
	/// @arg {String} _event_id		Event name that will be referenced when it is published, recommended naming scheme is "ev_whatever"	
	/// @arg {Function} _callback	The callback that will be run on the instance / struct once the event is published.
    static Subscribe = function( _id, _event_id, _callback ) {
        if ( is_undefined( event_struct[$ _event_id] ) ) {
            event_struct[$ _event_id] = [];
        }
        else if ( IsSubscribed( _id, _event_id ) ) {
            return false;
        }
        
        // Pushing the event to the event struct, along with an array containing the events ID and Function
        array_push( event_struct[$ _event_id], [_id, _callback] );
    }
    
	/// @func						Publish( _event_id, _callback )
	/// @desc						Will publish an event and run all the callbacks associated with the event specified.
	/// @arg {String} _event_id		Event name that will be referenced when it is published, recommended naming scheme is "ev_whatever"	
	/// @arg {Function} _callback	Callback that is run once an event is published, no callback HAS to be specified.
    static Publish = function( _event_id, _callback ) {
        var _sub_array = event_struct[$ _event_id];
        
        // If the event struct / array doesn't exist then return false and don't publish anything.
        if ( !is_undefined( _sub_array ) ) {
	        for( var i = ( array_length( _sub_array ) - 1 ); i >= 0; --i ) {
	            // Looping through the sub list and running the function on each sub
	            if ( instance_exists( _sub_array[i][0] ) ) {
	                print( $"Published : {i}" );
	                _sub_array[i][1]( _callback );
	            }
	            else {
	                // Delete the function from the sub
	                array_delete( _sub_array, i, 1 );
	            }
	        }
        }
        else {
        	return false;
        }
    }
    
	/// @func	Unsubscribe( _event_id, _event )
	/// @desc	Will unsubscribe an instance from an event
    static Unsubscribe = function( _event_id, _event ) {
        if ( !is_undefined( event_struct[$ _event_id] ) ) {
            var _pos = IsSubscribed( _event_id, _event );
            
            if ( _pos != -1 ) {
                array_delete( event_struct[$ _event], _pos, 1 );
            }
        }
        else {
            return false;
        }
    }  
    
	/// @func	Unsubscribe( _id )
	/// @desc	Will unsubscribe an instance from all events
    static UnsubscribeAll = function( _id ) {
		var _keys_arr = variable_struct_get_names( event_struct );
		
		for ( var i = ( array_length( _keys_arr ) - 1 ); i >= 0; --i ) {
			Unsubscribe( _id, _keys_arr[i] );
		}
    }
    
    static IsSubscribed = function( _id, _event_id ) {
        for( var i = 0; i < array_length( event_struct[$ _event_id] ); ++i ) {
            // If the item in the event struct matches the ID we are looking for, return it.
            if ( event_struct[$ _event_id][i][0] == _id ) {
                return i;
            }
        }
        
        return false;
    }
}

function test_eventhandler( _id ) {
    show_debug_message( "Running Test..." );

    eventhandler_subscribe( _id, "TestEvent", function() {
        show_debug_message( "Subscribed event!" );
    } );
    
    eventhandler_publish( "TestEvent", function() {
        show_debug_message( "This is an event." );
    } );
    
    show_debug_message( eventhandler.event_struct );
}

function eventhandler_subscribe( _id, _event_id, _func ) {
	with( obj_eventhandler ) {
		print( "Attempting Subscibe ..." );
		eventhandler.Subscribe( _id, _event_id, _func );
		return true;
	}
}

function eventhandler_publish( _event_id, _data = -1 ) {
	with( obj_eventhandler ) {
		show_debug_message( "Attempting Publish ..." );
        eventhandler.Publish( _event_id, _data );
        return true;
	}
}

function eventhandler_unsubscribe( _id, _event_id ) {
	with( obj_eventhandler ) {
		show_debug_message( "Attempting Unsubscribe ..." );
		eventhandler.Unsubscribe( _id, _event_id );
		return true;
	}
}

function eventhandler_unsubscribe_all( _id ) {
	with( obj_eventhandler ) {
		show_debug_message( "Attempting Unsubscribe All ..." );
		eventhandler.UnsubscribeAll( _id );
		return true;
	}
}

