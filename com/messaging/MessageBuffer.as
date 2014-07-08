package com.messaging
{
	import flash.utils.Dictionary;
	
	/**
	 * A tool that allows us to push messages to an async buffer
	 * so that processors can automatically read the messages within 
	 * an update cycle.
	 * 
	 * IMessageProcessors can only process a single type of message at 
	 * a time however, they are garanteed to recieve only the message type
	 * they are binded too.
	 * 
	 * @author James Wrightson http://www.earthshatteringcode.com
	 */
	public final class MessageBuffer
	{
		/**
		 * A callback that fires when a message is removed from the
		 * buffer when updated.
		 * 
		 * Function signiture:
		 * function(m:BaseMessage):void
		 */
		public var onMessageRemoved:Function = _defaultOnRemovedBehaviour;
		
		
		
		/**
		 * Update the message buffer so that related processors
		 * can recieve there message.
		 * 
		 * When the message has been dispatched, it will be removed
		 * from the buffer.
		 */
		[Inline]
		public function update():void
		{
			if (!_head)
				return;
			
			var msg:BaseMessage = _head;
			
			var msgType:Class = Object(msg).constructor;
			var processors:Array = _messageTypeMapping[msgType];
			
			for each (var processor:IMessageProcessor in processors)
			{
				processor.onMessage(msg);
			}
			
			remove(msg);
			
			if (onMessageRemoved) onMessageRemoved(msg);
		}

		/**
		 * Queue a message so that it can be processed
		 * via the update.
		 * 
		 * Warning:
		 * Ensure the message is not all ready inside an existing buffer.
		 * 
		 * @param	message
		 */
		[Inline]
		public function enqueue(message:BaseMessage):void
		{
			if (message._next || message._previous)
			{
				throw new Error("This message is in use, ensure it is not all ready in a buffer...");
			}
			
			if (!_head)
			{
				_head = _tail = message;
				message._next = message._previous = null;
			}
			else
			{
				_tail._next = message;
				message._previous = _tail;
				message._next = null;
				_tail = message;
			}
		}
		
		/**
		 * Have a look at the current message that is about to be processed.
		 * @return
		 */
		[Inline]
		public function peek():BaseMessage
		{
			return _head;
		}
		
		
		/**
		 * Add a message processor to the buffer so that relevent messages
		 * can be automatically dispatched to it.
		 * @param	processor
		 */
		public function registerProcessor(processor:IMessageProcessor):void
		{
			if (_processors.indexOf(processor) != -1)
			{
				throw new Error("Processor all ready in use");
			}
			
			_processors.push(processor);
			
			if (!_messageTypeMapping[processor.messageType])
			{
				_messageTypeMapping[processor.messageType] = [];
			}
			
			_messageTypeMapping[processor.messageType].push(processor);
		}
		
		/**
		 * Remove an existing processor from this buffer.
		 * 
		 * @param	processor
		 */
		public function unregisterProcessor(processor:IMessageProcessor):void
		{
			_processors.splice(_processors.indexOf(processor), 1);
			
			for (var key:*in _messageTypeMapping)
			{
				var classType:Class = key;
				var list:Array = _messageTypeMapping[key];
				
				var index:int = list.indexOf(processor);
				
				if (index != -1)
				{
					list.splice(index, 1);
					break;
				}
			}
		}
		
		/**
		 * Remove all of the processors within this buffer.
		 */
		public function clearProcessors():void
		{
			_processors.length = 0;
			_messageTypeMapping = new Dictionary();
		}
		
		/**
		 * Remove all of the processors within this buffer
		 * and remove all messages.
		 */
		public function dispose():void
		{
			clearProcessors();
			
			while (_head)
			{
				var msg:BaseMessage = _head;
				_head = msg._next;
				msg._previous = null;
				msg._next = null;
				
				onMessageRemoved(msg);
			}
			
			_tail = null;
		}
		
		[Inline]
		private  function remove(message:BaseMessage):void
		{
			if (_head == message)
			{
				_head = _head._next;
			}
			if (_tail == message)
			{
				_tail = _tail._previous;
			}
			
			if (message._previous)
			{
				message._previous._next = message._next;
			}
			
			if (message._next)
			{
				message._next._previous = message._previous;
			}
			
			 message._next = message._previous = null;
		}
		
		[Inline]
		private static const _defaultOnRemovedBehaviour:Function = function(m:BaseMessage):void { };

		
		//Store a linked list of messages...
		private var _head:BaseMessage;
		private var _tail:BaseMessage;
		
		private var _messageTypeMapping:Dictionary = new Dictionary();
		private var _processors:Vector.<IMessageProcessor> = new Vector.<IMessageProcessor>();
	
	}

}