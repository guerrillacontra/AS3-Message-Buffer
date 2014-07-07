package com.messaging 
{
	
	/**
	 * A message processor is used to recieve messages of a known type (described in messageType():Class)
	 * and process them.
	 * 
	 * @author James Wrightson http://www.earthshatteringcode.com
	 */
	public interface IMessageProcessor 
	{
		/**
		 * Return a type of BaseMessage that this processor
		 * handles.
		 */
		function get messageType():Class
		
		/**
		 * Do something when a message (where the message type is from messageType():Class).
		 * @param	msg
		 */
		function onMessage(msg:*):void
		
	}
	
}