package  
{
/**
 * ...火炮数据
 * @author Kanon
 */
public class Cannon 
{
    //打出去球的力量
    public var power:Number;
    /**当前鼠标和起始位置的夹角:弧度值*/
    public var angle:Number;
    /**起始位置x坐标*/
    public var startX:Number;
    /**起始位置y坐标*/
    public var startY:Number;
    public function Cannon(startX:Number, startY:Number, power:Number) 
    {
        this.startX = startX;
        this.startY = startY;
        this.power = power;
    }
    
    /**
     * 瞄准
     * @param	x   瞄准的x位置
     * @param	y   瞄准的y位置
     */
    public function aim(x:Number, y:Number):void
    {
        this.angle = Math.atan2(y - this.startY, x - this.startX);
    }
}
}