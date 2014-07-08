#AS3-Message-Buffer

A fast Message Buffer so that developers can listen for and process a message of a known type asynchronously.

This is an easy to use yet powerful tool that will allow you to dispatch messages (that you describe) to
message-processors automatically.

##Features

* Create custom messages that have a very low overhead
* Create custom processors that can recieve the message they want and process them automatically
* A message buffer that can asynchronously deliver messages to processors via an update call


##Example

>In this scenario an enemy can take damage and message any observer how much damage it has taken.

First of all we need to set up the message buffer so we can register processors
and dispatch messages:

```
			var buffer:MessageBuffer = new MessageBuffer();
			
			stage.addEventListener(Event.ENTER_FRAME, function(e:Event):void
				{
					buffer.update();
				});
```

It is up to you *when* the buffer gets updated, for this example a simple enter frame hook will work :)


Now we need a message type:

```
	public class EnemyHurtMessage extends BaseMessage 
	{
		public var damage:int = 0;
	}
```

Ensure all messages extend `BaseMessage`.

Now we have our message type, we can create a message processor to handle them:

```
	public class DamageMessageProcessor implements IMessageProcessor
	{
		public function get messageType():Class
		{
			return EnemyHurtMessage;
		}
		
		public function onMessage(inputMessage:*):void
		{
			var msg:EnemyHurtMessage = inputMessage;
			
			trace("Ouch I have been hurt " + msg.damage);
		}
	}
```

Finally we can register the processor to the message buffer and test it out:

```
			buffer.registerProcessor(new DamageMessageProcessor());
		
			var testMsg:EnemyHurtMessage = new EnemyHurtMessage();
			testMsg.damage = 10;
			
			buffer.enqueue(testMsg);
```

You will see the following output from tracing:

>Ouch I have been hurt 10

Remember, unlike standard observable tools such as Signals the message-buffer
is dispatched within the update making it asynchronous!

##Advanced example

We can take the previous example a step further by adding object pooling
(the object pool can be found https://github.com/guerrillacontra/AS3-Automatic-Object-Pool):

```
			var pool:ObjectPool = new ObjectPool(1);
			
			var buffer:MessageBuffer = new MessageBuffer();
			
			buffer.onMessageRemoved = function(m:BaseMessage):void
			{
				if (pool.isFromPool(m))
				{
					pool.recycle(m);
				}
				
			};
			
			stage.addEventListener(Event.ENTER_FRAME, function(e:Event):void
				{
					buffer.update();
				});
			
			buffer.registerProcessor(new DamageMessageProcessor());
			
			var testMsg:EnemyHurtMessage = pool.fetch(EnemyHurtMessage);
			testMsg.damage = 10;
			
			buffer.enqueue(testMsg);
```

By overriding the ```onMessageRemoved``` callback we can provide custom behaviour
and in this situation, recycle a pooled message automatically.

##Advanced example with a functional processor

The above example can also be written with a functional processor, very useful
for simple processors.

```
			var pool:ObjectPool = new ObjectPool(1);
			
			var buffer:MessageBuffer = new MessageBuffer();
			
			buffer.onMessageRemoved = function(m:BaseMessage):void
			{
				if (pool.isFromPool(m))
				{
					pool.recycle(m);
				}
				
			};
			
			stage.addEventListener(Event.ENTER_FRAME, function(e:Event):void
				{
					buffer.update();
				});
			
			
			var onAttacked:Function = function(m:EnemyHurtMessage):void
			{
			   trace("Ouch I have been hurt " + m.damage);
			};
			
			buffer.registerProcessor(new FunctionalMessageProcessor(EnemyHurtMessage, onAttacked));
			
			var testMsg:EnemyHurtMessage = pool.fetch(EnemyHurtMessage);
			testMsg.damage = 10;
			
			buffer.enqueue(testMsg);
```
