package  
{
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import net.hires.debug.Stats;
import utils.MathUtil;
/**
 * ...泡泡龙测试
 * @author Kanon
 */
public class BubbleTest extends Sprite 
{
    private var bubble:Bubble;
    private var cannon:Cannon;
    private var aimMc:Sprite;
    private var radius:Number = 30;
    public function BubbleTest() 
    {
        stage.align = StageAlign.TOP_LEFT;
        this.bubble = new Bubble(this, 15, 1, 6, this.radius);
        this.bubble.range = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        this.cannon = new Cannon(stage.stageWidth * .5, stage.stageHeight, 20);
        this.initUI();
        this.addChild(new Stats());
        this.addEventListener(Event.ENTER_FRAME, loop);
        stage.addEventListener(MouseEvent.CLICK, mouseClickHander);
    }
    
    private function mouseClickHander(event:MouseEvent):void 
    {
        this.cannon.aim(mouseX, mouseY);
        var vx:Number = Math.cos(this.cannon.angle) * this.cannon.power;
        var vy:Number = Math.sin(this.cannon.angle) * this.cannon.power;
        this.bubble.addBubble(this.cannon.startX, this.cannon.startY - this.radius, vx, vy, 1);
    }
    
    /**
     * 初始化UI
     */
    private function initUI():void
    {
        this.aimMc = new AimMc();
        this.aimMc.x = this.cannon.startX;
        this.aimMc.y = this.cannon.startY;
        this.addChild(this.aimMc);
    }
    
    private function loop(event:Event):void 
    {
        this.cannon.aim(mouseX, mouseY);
        this.aimMc.rotation = MathUtil.rds2dgs(this.cannon.angle);
        this.bubble.update();
        this.bubble.render();
    }
    
}
}