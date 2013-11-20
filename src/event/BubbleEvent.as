package event 
{
import flash.events.Event;
/**
 * ...泡泡龙事件
 * @author Kanon
 */
public class BubbleEvent extends Event 
{
	public static const UPDATE:String = "update";
	public function BubbleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
	{ 
		super(type, bubbles, cancelable);
	} 
	
	public override function clone():Event 
	{ 
		return new BubbleEvent(type, bubbles, cancelable);
	} 
	
	public override function toString():String 
	{ 
		return formatToString("BubbleEvent", "type", "bubbles", "cancelable", "eventPhase"); 
	}
	
}
}