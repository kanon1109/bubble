package  
{
import utils.Random;
import event.BubbleEvent;
import flash.display.MovieClip;
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
    private var color:uint;
    private var colorType:int = 5;
    private var cMc:MovieClip;
    public function BubbleTest() 
    {
        stage.align = StageAlign.TOP_LEFT;
        this.bubble = new Bubble(this, 1, 6, this.radius, this.colorType);
        this.bubble.addEventListener(BubbleEvent.UPDATE, updateHandler);
        this.bubble.range = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        this.cannon = new Cannon(stage.stageWidth * .5, stage.stageHeight, 20);
        this.initUI();
        this.color = Random.randint(1, this.colorType);
        
        this.cMc = this.getChildByName("c_mc") as MovieClip;
        this.cMc.gotoAndStop(this.color);
        
        //this.addChild(new Stats());
        this.addEventListener(Event.ENTER_FRAME, loop);
        stage.addEventListener(MouseEvent.CLICK, mouseClickHander);
    }
	
	private function updateHandler(event:BubbleEvent):void 
	{
		//trace(this.bubble.rows);
	}
    
    private function mouseClickHander(event:MouseEvent):void 
    {
        this.cannon.aim(mouseX, mouseY);
        var vx:Number = Math.cos(this.cannon.angle) * this.cannon.power;
        var vy:Number = Math.sin(this.cannon.angle) * this.cannon.power;
        this.bubble.shotBubble(this.cannon.startX, this.cannon.startY - this.radius, vx, vy, this.color);
        this.color = Random.randint(1, this.colorType);
        this.cMc.gotoAndStop(this.color);
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