lu = require('externals/luaunit/luaunit')
require('flatten')



function test_current_equals_current()
    local sut = Stack.Create()
    lu.assertEquals(sut._current, sut._current)
end

function test_head_points_itself()
    local sut = Stack.Create()
    local head = sut._head
    local actual = head.after
    lu.assertEquals(head, actual)
end


function test_tail_points_itself()
    local sut = Stack.Create()
    local head = sut._head
    local tail = head.before
    local actual = tail.before
    lu.assertEquals(tail, actual)
end

function test_tail_points_head()
    local sut = Stack.Create()
    local head = sut._head
    local tail = head.before
    local actual = tail.after
    lu.assertEquals(head, actual)
end

function test_head_points_to_tail_on_empty_stack()
    local sut = Stack.Create()
    local head = sut._head
    lu.assertNotNil(head)
    local tail = sut._head.before
    lu.assertFalse(head == tail)
    local head_again = tail.after
    lu.assertEquals(head, head_again)
end


 function test_current_starts_at_top()
     local sut = Stack.Create()
     assert(sut._head ~= sut._head.before)
     local actual = sut:is_at_top()
     lu.assertTrue(actual)
end

function test_error_logged_at_go_back_when_at_bottom()
    -- setup
    local error_logged = false
    local old_print_important = print_important
    print_important = function() error_logged = true end
    -- exercise
    local sut = Stack.Create()
    sut:go_back()
    -- validate
    lu.assertTrue(error_logged)
    -- cleanup
    print_important = old_print_important
end

 function test_go_back_on_empty_stack_keeps_current_at_top()
    -- setup
    local old_print_important = print_important
    print_important = function()  end
    -- exercise
    local sut = Stack.Create()
    sut:go_back()
    -- validate
    local actual = sut:is_at_top()
    lu.assertTrue(actual)
    -- cleanup
    print_important = old_print_important
end

function test_push_inserts_into_list()
    local sut = Stack.Create()
    local head = sut._head
    local tail = sut._head.before
    local event1 = {type="1", apply=function() end}
    sut:push(event1)
    lu.assertEquals(head, sut._head)
    lu.assertTrue(head ~= sut._head.before)
    lu.assertTrue(tail ~= sut._head.before)
    local new_node = sut._head.before
    lu.assertEquals(new_node, head.before)
    lu.assertEquals(head, new_node.after)
    lu.assertEquals(tail, new_node.before)
    lu.assertEquals(new_node, tail.after)
end

function test_push_puts_new_node_as_current()
    local sut = Stack.Create()
    local head = sut._head
    local tail = sut._head.after
    local event1 = {type="1", apply=function() end}
    sut:push(event1)
    lu.assertTrue(sut._current ~= head)
    lu.assertTrue(sut._current ~= tail)
end

function test_no_longer_at_top_of_stack_after_go_back()
    local sut = Stack.Create()
    local event1 = {
        type="1",
        undo = function() end,
        redo = function() end
    }

    local event2 = {
        type="2",
        undo = function() end,
        redo = function() end
    }

    sut:push(event1)
    sut:push(event2)
    sut:go_back()
    local actual = sut:is_at_top()
    lu.assertFalse(actual)
end


function test_go_back_undoes_current_event()
    -- If the history event uses 'undo' then we use the current event.
    local undone = nil
    local sut = Stack.Create()
    local event1 = {type="1", undo = function() undone = 1 end}
    local event2 = {type="2", undo = function() undone = 2 end}
    sut:push(event1)
    sut:push(event2)
    sut:go_back()
    lu.assertEquals(undone, 2)
end

function test_go_back_changes_current_after_undo()
    local undone = nil
    local sut = Stack.Create()
    local event1 = {type="1", undo = function() undone = -1 end}
    local event2 = {type="2", undo = function() undone = -2 end}
    local event3 = {type="3", undo = function() undone = -3 end}
    sut:push(event1)
    sut:push(event2)
    sut:push(event3)
    sut:go_back()
    lu.assertEquals(undone, -3)
    sut:go_back()
    lu.assertEquals(undone, -2)
end


function test_go_back_undoes_1_event()
    -- If the current event is an applied event then when we go back
    -- nothing is executed on the event.  If the previous event is
    --  and apply event, then apply is called.  If the previous event
    --  is an undo event then undo is called, and the current event
    --  is the one before the undo event.

    -- setup
    local redone_event = nil
    local undone_event = nil
    local sut = Stack.Create()

    local event1 = {
      type="1",
      undo = function() undone_event = 1 end
    }

    local event2 = {
      type="2",
      undo = function()
  	    undone_event = 2
      end,
      redo = function()
        redone_event=2
      end,
    }

    local event3 = {
        type="3",
        undo = function() undone_event = 3 end
    }

    sut:push(event1)
    sut:push(event2)
    sut:push(event3)
    sut:go_back()
    -- validate
    lu.assertEquals(undone_event, 3)
    lu.assertEquals(redone_event, nil)
end

function test_go_forward_redoes_the_current_event()
    -- setup
    local applied_event = nil
    local sut = Stack.Create()

    local event1 = {
        type="1",
        undo = function() applied_event = -1 end,
        redo = function() applied_event = 1 end,
    }

    local event2 = {
        type="2",
        undo = function() applied_event = -2 end,
        redo = function() applied_event = 2 end,
    }

    local event3 = {
      type="3",
        undo = function() applied_event = -3 end,
        redo = function() applied_event = 3 end,
    }

    local event4 = {
        type="4",
        undo = function() applied_event = -4 end,
        redo = function() applied_event = 4 end,
    }

    sut:push(event1)
    sut:push(event2)
    sut:push(event3)
    sut:push(event4)
    sut:go_back()
    lu.assertEquals(applied_event, -4)
    sut:go_back()
    lu.assertEquals(applied_event, -3)
    -- Exercise
    sut:go_forward()
    lu.assertEquals(applied_event, 3)
    sut:go_forward()
    -- validate
    lu.assertEquals(applied_event, 4)
end


function test_go_forwared_moves_the_current_event()
    -- setup
    local applied_event = nil
    local sut = Stack.Create()

    local event1 = {
       type="1",
       undo = function() applied_event = -1 end,
       redo = function() applied_event = 1 end
    }

    local event2 = {
        type="2",
        undo = function() applied_event = -2 end,
        redo = function() applied_event = 2 end
    }

    local event3 = {
        type="3",
        undo = function() applied_event = -3 end,
        redo = function() applied_event = 3 end
    }

    sut:push(event1)
    sut:push(event2)
    sut:push(event3)
    sut:go_back()
    lu.assertEquals(applied_event, -3)
    sut:go_back()
    lu.assertEquals(applied_event, -2)
    -- Exercise
    sut:go_forward()
    lu.assertEquals(applied_event, 2)
    sut:go_forward()
    -- validate
    lu.assertEquals(applied_event, 3)
end

function test_delete_node_updates_links()
    -- setup
    local sut = Stack.Create()
    local head = sut._head
    local tail = sut._head.before
    local event1 = {apply = function()  end}
    sut:push(event1)
    -- exercise
    sut:_delete_node(sut._head.before)
    -- validate
    lu.assertEquals(tail, sut._head.before)
    lu.assertEquals(head, sut._head.before.after)
end


function test_push_erases_all_above_current()
    -- setup
    local applied_event = nil
    local sut = Stack.Create()

    local event1 = {
        id=1,
        undo = function() applied_event = -1 end,
        redo = function() applied_event = 1 end,
    }

    local event2 = {
        id=2,
        undo = function() applied_event = -2 end,
        redo = function() applied_event = 2 end,
    }

    local event3 = {
        id=3,
        undo = function() applied_event = -3 end,
        redo = function() applied_event = 3 end,
    }

    local event4 = {
        id=4,
        undo  = function() applied_event = -4 end,
        redo = function() applied_event = 4 end,
    }

    sut:push(event1)
    sut:push(event2)
    sut:push(event3)
    sut:go_back()
    lu.assertEquals(applied_event, -3)
    sut:go_back()
    lu.assertEquals(applied_event, -2)
    -- Exercise
    sut:push(event4)
    sut:go_back()
    lu.assertEquals(applied_event, -4)
    sut:go_back()
    lu.assertEquals(applied_event, -1)
    sut:go_forward()
    lu.assertEquals(applied_event, 1)
    sut:go_forward()
    lu.assertEquals(applied_event, 4)
end

function test_empty_stack_size_is_zero()
  local sut = Stack.Create()
  local actual = sut:size()
  lu.assertEquals(0, actual)
end

function test_push_adds_to_size()
    local event1 = {}
    local sut = Stack.Create()
    sut:push(event1)
    local actual = sut:size()
    lu.assertEquals(actual, 1)
end

function test_push_eraseing_decreases_size()
    -- setup
    local applied_event = nil
    local sut = Stack.Create()
    local event1 = {undo = function() applied_event = -1 end}
    local event2 = {undo = function() applied_event = -2 end}
    local event3 = {undo = function() applied_event = -3 end}
    local event4 = {undo = function() applied_event = -4 end}
    sut:push(event1)
    sut:push(event2)
    sut:push(event3)
    sut:go_back()
    lu.assertEquals(applied_event, -3)
    sut:go_back()
    lu.assertEquals(applied_event, -2)
    -- Exercise
    sut:push(event4)
    local actual = sut:size()
    -- Validate
    lu.assertEquals(actual, 2)
end

function test_pushing_past_capacity_erases_oldest_event()
    -- setup
    local applied_event = nil
    local sut = Stack.Create()
    sut._capacity = 3
    local tail = sut._head.before
    local event1 = {apply = function() applied_event = 1 end}
    local event2 = {apply = function() applied_event = 2 end}
    local event3 = {apply = function() applied_event = 3 end}
    local event4 = {apply = function() applied_event = 4 end}
    sut:push(event1)
    sut:push(event2)
    sut:push(event3)
    lu.assertEquals(sut:size(), 3)
    -- Exercise
    sut:push(event4)
    local actual = sut:size()
    -- Validate
    lu.assertEquals(actual, 3)
end

function test_top_returns_null_for_empty_stack()
    local sut = Stack.Create()
    local actual = sut.top()
    lu.assertEquals(actual, nil)
end

function test_top_returns_most_recent_event()
    -- setup
    local applied_event = nil
    local sut = Stack.Create()
    local event1 = {id=1}
    local event2 = {id=2}
    sut:push(event1)
    sut:push(event2)
    -- exercise
    local top = sut:top()
    -- validate
    lu.assertEquals(top.id, 2)
end

-- Test fix for bug where we undo an event and then
-- redo past the top of the stack, then sit on
-- the head, and then make a move.
-- The new event is to be inserted after the head.
function test_move_after_past_top()
  -- Setup
  local old = print_important
  print_important = function() end
  -- Exercise
  local applied = nil
  local sut = Stack.Create()
  local event1 = {
      event_id = 1,
      undo = function() applied=-1 end,
      redo = function() applied =1 end
  }

  local event2 = {
    event_id = 1,
    undo = function() applied=-2 end,
    redo = function() applied=2 end
}

  lu.assertEquals(sut:size(), 0)
  sut:push(event1)
  lu.assertEquals(sut:size(), 1)
  sut:push(event2)
  lu.assertEquals(sut:size(), 2)
  sut:go_back()
  lu.assertEquals(-2, applied)
  sut:go_forward()
  lu.assertEquals(2, applied)

  sut:go_forward()
  lu.assertEquals(2, applied)

  local event3 = {
    event_id = 3,
    undo = function()
        applied=-3
    end
  }
  sut:push(event3)
  lu.assertEquals(sut:size(), 3)

  -- Verify
  sut.top().undo()
  lu.assertEquals(applied, -3)

  -- Clean up
  print_important = old
end

-- If a history event does not support rename_guid
-- then the method call is not attempted.
function test_rename_guid_does_not_call_event()
    local sut = Stack.Create()
    local event1 = {}
    sut:push(event1)
    local old_guid = "FOO"
    local new_guid = "BAR"
    sut:rename_guid(old_guid, new_guid)
end

-- If a history event supports rename_guid
-- then the method call mad.
function test_rename_guid_does_not_call_event()
    local sut = Stack.Create()
    local called = nil
    local event1 = {
      rename_guid = function(self, old_guid, new_guid)
        called = {old_guid=old_guid, new_guid=new_guid}
     end}
    sut:push(event1)
    local old_guid = "FOO"
    local new_guid = "BAR"
    sut:rename_guid(old_guid, new_guid)
    -- Verify
    lu.assertEquals(called.old_guid, old_guid)
    lu.assertEquals(called.new_guid, new_guid)
end

function test_is_undoable_false_on_empty_stack()
  -- Nothing to undo
  local sut = Stack.Create()
  local actual = sut:is_undoable()
  lu.assertFalse(actual)
end


function test_is_undoable_true_at_top_of_stack()
  local sut = Stack.Create()
  local event1 = {}
  sut:push(event1)
  local actual = sut:is_undoable()
  lu.assertTrue(actual)
end

function test_is_undoable_false_at_bottom_of_stack()
  local sut = Stack.Create()
  local event1 = {
    undo = function() end,
  }
  sut:push(event1)
  sut:go_back()
  local actual = sut:is_undoable()
  lu.assertFalse(actual)
end

function test_is_undoable_true_in_middle_of_stack()
  local sut = Stack.Create()
  local event = {
    undo = function() end,
  }
  sut:push(event)
  sut:push(event)
  sut:go_back()
  local actual = sut:is_undoable()
  lu.assertTrue(actual)
end

function test_is_redoable_false_on_empty_stack()
  -- Nothing to redo
  local sut = Stack.Create()
  local actual = sut:is_redoable()
  lu.assertFalse(actual)
end

function test_is_redoable_false_at_top_of_stack()
  local sut = Stack.Create()
  local event = {
    undo = function() end,
  }
  sut:push(event)
  local actual = sut:is_redoable()
  lu.assertFalse(actual)
end

function test_is_redoable_false_at_top_of_stack_two_events()
  local sut = Stack.Create()
  local event = {
    undo = function() end,
  }
  sut:push(event)
  sut:push(event)
  local actual = sut:is_redoable()
  lu.assertFalse(actual)
end

function test_is_redoable_true_at_bottom_of_stack()
  local sut = Stack.Create()
  local event = {
    undo = function() end,
  }
  sut:push(event)
  sut:go_back()
  local actual = sut:is_redoable()
  lu.assertTrue(actual)
end

function test_is_redoable_true_in_middle_of_stack()
  local sut = Stack.Create()
  local event = {
    undo = function() end,
  }
  sut:push(event)
  sut:push(event)
  sut:go_back()
  local actual = sut:is_redoable()
  lu.assertTrue(actual)
end

function test_is_redoable_false_after_move_to_top_of_stack()
  local sut = Stack.Create()
  local event = {
    undo = function() end,
    redo = function() end,
  }
  sut:push(event)
  sut:push(event)
  sut:go_back()
  sut:go_forward()
  local actual = sut:is_redoable()
  lu.assertFalse(actual)
end

os.exit( lu.LuaUnit.run() )
