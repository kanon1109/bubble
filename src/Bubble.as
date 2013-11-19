package  
{
import data.BubbleVo;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Rectangle;
import util.MathUtil;
/**
 * ...泡泡龙算法
 * @author Kanon
 */
public class Bubble 
{
    //泡泡数据列表
    private var bubbleList:Array;
    //最大列数
    private var maxColumns:int;
    //数量
    private var num:int;
    //半径
    private var radius:Number;
    //外部容器
    private var stage:DisplayObjectContainer;
    //移动范围
    private var _range:Rectangle;
    //射出的泡泡列表
    private var shotBubbleList:Array;
    public function Bubble(stage:DisplayObjectContainer, num:int, 
                           maxColumns:int, radius:Number)
    {
        this.stage = stage;
        this.maxColumns = maxColumns;
        this.num = num;
        this.radius = radius;
        this.initData();
        this.initDraw();
    }
    
    /**
     * 初始化地图数据
     */
    private function initData():void
    {
        this.bubbleList = [];
        this.shotBubbleList = [];
        var bVo:BubbleVo;
        var rows:int = 1;
        var column:int = 1;
        var startX:Number = 0;
        var startY:Number = this.radius;
        //间距
        var dis:Number = 0;
        //最大列数
        var maxColumns:int;
        for (var i:int = 1; i <= this.num; i += 1)
        {
            bVo = new BubbleVo();
            bVo.color = 1;
            bVo.isCheck = false;
            bVo.radius = this.radius;
            bVo.rows = rows;
            bVo.column = column;
            if (rows % 2 != 0)
            {
                //单数行
                startX = bVo.radius;
                maxColumns = this.maxColumns;
            }
            else 
            {
                //双数行
                //起始位置向前移动一个半径距离
                startX = bVo.radius * 2;
                dis = bVo.radius - bVo.radius * Math.cos(MathUtil.dgs2rds(45));
                //数量少一个
                maxColumns = this.maxColumns - 1;
            }
            bVo.x = startX + (column - 1) * bVo.radius * 2;
            bVo.y = startY + ((rows - 1) * bVo.radius * 2 - (rows - 1) * dis);
            column++;
            if (column > maxColumns)
            {
                rows++;
                column = 1;
            }
            this.bubbleList.push(bVo);
        }
    }
    
    /**
     * 初始化绘制泡泡数据
     */
    private function initDraw():void
    {
        var bVo:BubbleVo;
        var length:int = this.bubbleList.length;
        for (var i:int = 0; i < length; i += 1)
        {
            bVo = this.bubbleList[i];
            this.drawBubble(bVo);
        }
    }
    
    /**
     * 添加一个可移动的泡泡
     * @param	x      起始位置
     * @param	y      起始位置
     * @param	vx          x向量
     * @param	vy          y向量
     * @param	color       颜色
     */
    public function addBubble(x:Number, y:Number, 
                              vx:Number, vy:Number, 
                              color:uint):void
    {
        if (!this.bubbleList) return;
        var bVo:BubbleVo = new BubbleVo();
        bVo.x = x;
        bVo.y = y;
        bVo.vx = vx;
        bVo.vy = vy;
        bVo.color = color;
        bVo.radius = 30;
        bVo.isCheck = false;
        this.drawBubble(bVo);
        this.bubbleList.push(bVo);
        this.shotBubbleList.push(bVo);
    }
    
    /**
     * 绘制一个泡泡
     * @param	bVo   泡泡数据
     */
    private function drawBubble(bVo:BubbleVo):void
    {
        bVo.display = new Sprite();
        Sprite(bVo.display).graphics.lineStyle(1, 0);
        Sprite(bVo.display).graphics.beginFill(0xFF00FF);
        Sprite(bVo.display).graphics.drawCircle(0, 0, bVo.radius);
        Sprite(bVo.display).graphics.endFill();
        bVo.display.x = bVo.x;
        bVo.display.y = bVo.y;
        this.stage.addChild(bVo.display);
    }
    
    /**
     * 碰撞检测
     * @param	bVo    泡泡数据
     */
    private function hitTest(bVo:BubbleVo):void
    {
        var length:int = this.shotBubbleList.length;
        if (length == 0) return;
        var shotBVo:BubbleVo;
        var bVo:BubbleVo;
        for (var i:int = 0; i < length; i += 1)
        {
            shotBVo = this.shotBubbleList[i];
            if (shotBVo != bVo)
            {
                if (Math.abs(shotBVo.x - bVo.x) <= radius && 
                    Math.abs(shotBVo.y - bVo.y) <= radius)
                {
                    this.autoAbsorption(shotBVo, bVo);
                    this.shotBubbleList.splice(i, 1);
                    trace(bVo.rows);
                    break;
                }
            }
        }
    }
    
    /**
     * 自动吸附
     * @param	shotBVo     发射的泡泡数据
     * @param	bVo         泡泡数据
     */
    private function autoAbsorption(shotBVo:BubbleVo, bVo:BubbleVo):void
    {
        if (bVo.rows % 2 != 0)
        {
            
        }
        else
        {
            
        }
        
    }
    
    /**
     * 更新数据
     */
    public function update():void
    {
        if (!this.bubbleList) return;
        var bVo:BubbleVo;
        var length:int = this.bubbleList.length;
        for (var i:int = 0; i < length; i += 1)
        {
            bVo = this.bubbleList[i];
            bVo.x +=  bVo.vx;
            bVo.y +=  bVo.vy;
            this.checkRange(bVo, this.range);
            this.hitTest(bVo);
        }
    }
    
    /**
     * 渲染
     */
    public function render():void
    {
        if (!this.bubbleList) return;
        var bVo:BubbleVo;
        var length:int = this.bubbleList.length;
        for (var i:int = 0; i < length; i += 1)
        {
            bVo = this.bubbleList[i];
            if (bVo.display)
            {
                bVo.display.x = bVo.x;
                bVo.display.y = bVo.y;
            }
        }
    }
    
    /**
     * 判断泡泡的移动范围
     * @param	vo      泡泡数据
     * @param	rect    移动范围
     */
    public function checkRange(vo:BubbleVo, rect:Rectangle):void
    {
        if (!rect) return;
        if (vo.x < rect.left + vo.radius || 
            vo.x > rect.right - vo.radius)
            vo.vx *= -1;
    }
    
    /**
     * 销毁
     */
    public function destroy():void
    {
        var bVo:BubbleVo;
        var length:int;
        for (var i:int = length - 1; i >= 0; i -= 1) 
        {
            bVo = this.bubbleList[i];
            if (bVo.display && bVo.display.parent)
                bVo.display.parent.removeChild(bVo.display);
            bVo.display = null;
            this.bubbleList.splice(i, 1);
        }
        this.bubbleList = null;
        this.shotBubbleList = null;
        this.range = null;
        this.stage = null;
    }
    
    /**
     * 移动范围
     */
    public function get range():Rectangle { return _range; };
    public function set range(value:Rectangle):void 
    {
        _range = value;
    }
    
}
}