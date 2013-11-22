package event 
{
import data.BubbleVo;
import flash.events.Event;
/**
 * ...泡泡龙事件
 * @author Kanon
 */
public class BubbleEvent extends Event 
{
    /**更新泡泡数量事件*/
	public static const UPDATE:String = "update";
    /**销毁泡泡显示事件*/
	public static const REMOVE_BUBBLE:String = "removeBubble";
    /**泡泡数据*/
    public var bVo:BubbleVo;
	public function BubbleEvent(type:String, bVo:BubbleVo=null, bubbles:Boolean=false, cancelable:Boolean=false) 
	{ 
        this.bVo = bVo;
		super(type, bubbles, cancelable);
	} 
	
	public override function clone():Event 
	{ 
		return new BubbleEvent(type, bVo, bubbles, cancelable);
	} 
	
	public override function toString():String 
	{ 
		return formatToString("BubbleEvent", "type", "bubbles", "cancelable", "eventPhase"); 
	}
	
}
}