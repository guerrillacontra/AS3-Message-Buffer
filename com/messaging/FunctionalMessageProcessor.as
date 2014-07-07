package com.messaging 
{
	/**
	 * A message processor that can handle a message of a known type
	 * via a closure.
	 * 
	 * Useful tool if you do not want to write your own implements of 
	 * IMessageProcessor.
	 * 
	 * @author James Wrightson http://www.earthshatteringcode.com
	 */
	public final class FunctionalMessageProcessor implements IMessageProcessor 
	{
	
		/**
		 * Create a FunctionalMessageProcessor.
		 * @param	messageType The type of message this processor handles
		 * @param	onMessage A function callback that happens when a message is recieved.
		 * 						function(m:YourMessageTypeHere):void
		 */
		public function FunctionalMessageProcessor(messageType:Class, onMessage:Function):void 
		{
			_messageType = messageType;
			_onMessage = onMessage;
		}
		
		
		public function get messageType():Class 
		{
			return _messageType;
		}
		
		public function onMessage(msg:*):void 
		{
			_onMessage(msg);
		}
		
		private var _messageType:Class;
		private var _onMessage:Function;
		
	}

}