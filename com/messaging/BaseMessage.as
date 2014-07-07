package com.messaging 
{
	/**
	 * An abstract message that is used to
	 * provide processors with information.
	 * 
	 * You will want to extend this class and add
	 * your own specific data to pass to the processors.
	 * 
	 * @author James Wrightson http://www.earthshatteringcode.com
	 */
	public class BaseMessage 
	{
		//Used for an intrusive linked list (performance).
		internal var _previous:BaseMessage;
		internal var _next:BaseMessage;	
	}

}