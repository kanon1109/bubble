package data 
{
    import flash.display.DisplayObject;
/**
 * ...泡泡数据
 * @author Kanon
 */
public class BubbleVo 
{
    /**颜色*/
    public var color:uint;
    /**是否被检查过*/
    public var isCheck:Boolean;
    /**显示对象*/
    public var display:DisplayObject;
    /**x坐标*/
    public var x:Number;
    /**y坐标*/
    public var y:Number;
    /**半径*/
    public var radius:Number;
    /**横向向量*/
    public var vx:Number = 0;
    /**纵向向向量*/
    public var vy:Number = 0;
    /**行数*/
    public var rows:int;
    /**列表数*/
    public var column:int;
}
}