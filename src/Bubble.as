package  
{
import data.BubbleVo;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import utils.MathUtil;
import utils.TraceUtil;
/**
 * ...泡泡龙算法
 * @author Kanon
 */
public class Bubble 
{
    //泡泡数据列表
    private var bubbleList:Array;
    //泡泡字典用于快速遍历泡泡并且让其移动
    private var bubbleDict:Dictionary;
    //列数
    private var columns:int;
    //行数
    private var rows:int;
    //半径
    private var radius:Number;
    //碰撞检测范围
    private var hitRange:Number;
    //外部容器
    private var stage:DisplayObjectContainer;
    //移动范围
    private var _range:Rectangle;
    //射出的泡泡列表
    private var shotBubbleList:Array;
    public function Bubble(stage:DisplayObjectContainer, 
                           rows:int, columns:int, radius:Number)
    {
        this.stage = stage;
        this.rows = rows;
        this.columns = columns;
        this.radius = radius;
        this.hitRange = radius * 2 - 5;
        this.initData();
        this.initDraw();
    }
    
    /**
     * 初始化地图数据
     */
    private function initData():void
    {
        this.bubbleList = [];
        this.bubbleDict = new Dictionary();
        this.shotBubbleList = [];
        var bVo:BubbleVo;
        //最大列数
        var maxColumns:int;
        var point:Point;
        //偶数行的数量
        var evenRowNum:int = this.rows % 2 == 0 ? this.rows / 2 : (this.rows + 1) / 2 - 1;
        var num:int = this.rows * this.columns - evenRowNum;
        trace("num", num);
        //循环行数
        for (var row:int = 0; row < this.rows; row += 1)
        {
            this.bubbleList[row] = [];
            if (row % 2 == 1) maxColumns = this.columns - 1; //双数行
            else maxColumns = this.columns; //单数行
            //循环列数
            for (var column:int = 0; column < maxColumns; column += 1)
            {
                if (num > 0)
                {
                    bVo = new BubbleVo();
                    bVo.color = 1;
                    bVo.isCheck = false;
                    bVo.radius = this.radius;
                    bVo.row = row;
                    bVo.column = column;
                    point = this.getBubblePos(row, column);
                    bVo.x = point.x;
                    bVo.y = point.y;
                    this.bubbleList[row][column] = bVo;
                    this.bubbleDict[bVo] = bVo;
                    num--;
                }
                else this.bubbleList[row][column] = null;
            }
        }
        //TraceUtil.dump(this.bubbleList, "this.bubbleList");
    }
    
    /**
     * 根据行列计算泡泡应该放置的位置
     * @param	row        行数
     * @param	column     列数
     * @return  位置坐标
     */
    private function getBubblePos(row:int, column:int):Point
    {
        var startX:Number;
        var startY:Number = this.radius;
        if (row % 2 == 0) startX = this.radius; //单数行
        else startX = this.radius * 2; //双数行 起始位置向前移动一个半径距离
        //行间距
        var dis:Number = this.radius - this.radius * Math.cos(MathUtil.dgs2rds(45));
        return new Point(startX + column * this.radius * 2, startY + (row * this.radius * 2 - row * dis))
    }
    
    /**
     * 初始化绘制泡泡数据
     */
    private function initDraw():void
    {
        var bVo:BubbleVo;
        for each (bVo in this.bubbleDict) 
        {
            this.drawBubble(bVo);
        }
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
				if (MathUtil.distance(shotBVo.x, shotBVo.y, bVo.x, bVo.y) <= this.hitRange)
				{
					this.shotBubbleList.splice(i, 1);
                    //自动吸附
					this.autoAbsorption(shotBVo, bVo);
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
        //判断是否超过最后一行
        if (bVo.row + 1 >= this.rows) this.addNewRow();
        var arr:Array = this.getRoundBubblePos(bVo.row, bVo.column);
        var length:int = arr.length;
        //trace("length", length);
		if(length == 0) return;
        //距离列表
        var disArr:Array = [];
        var point:Point;
        var bVo:BubbleVo;
        var row:int;
        var column:int;
        for (var i:int = 0; i < length; i++) 
        {
            row = arr[i][0];
            column = arr[i][1];
            bVo = this.bubbleList[row][column];
            //如果此处没有泡泡数据则计算射出的球到这些点的距离
            if (!bVo) 
            {
                point = this.getBubblePos(row, column);
                //保存所有距离
                disArr.push( { "distance": MathUtil.distance(shotBVo.x, shotBVo.y, point.x, point.y), 
                               "index":i, 
                               "point":point } );
            }
        }
        //排序 最小距离在前
        disArr.sortOn("distance", Array.NUMERIC);
        var o:Object = disArr[0];
        i = o.index;
        //设置行列
        shotBVo.row = arr[i][0];
        shotBVo.column = arr[i][1];
        shotBVo.x = o.point.x;
        shotBVo.y = o.point.y;
        shotBVo.vx = 0;
        shotBVo.vy = 0;
        this.bubbleList[shotBVo.row][shotBVo.column] = shotBVo;
    }
    
    /**
     * 根据行列获取周围6个泡泡行列
     * @param	row         行数
     * @param	column      列数
     * @return  周围6个泡泡的行列的列表
     */
    private function getRoundBubblePos(row:int, column:int):Array
    {
        var arr:Array = [];
        //最大列数
        var maxColumns:int;
        var index:int;
        if (row % 2 == 0) maxColumns = this.columns; //单行
        else maxColumns = this.columns - 1; //双行
        var bVo:BubbleVo;
        //左右2个
        if (column - 1 >= 0)
            arr.push([row, column - 1]);
        if (column + 1 < maxColumns)
            arr.push([row, column + 1]);
        //判断上下两行是单行或双行
        if ((row - 1) % 2 == 0)
        {
            //单行
            index = 1;
            maxColumns = this.columns;
        }
        else
        {
            //双行
            index = -1;
            maxColumns = this.columns - 1;
        }
        //上面2个
        if (row - 1 >= 0)
        {
            if (column + index >= 0 && 
                column + index < maxColumns)
                arr.push([row - 1, column + index]);
            if (column >= 0 && 
                column < maxColumns)
                arr.push([row - 1, column]);
        }
        
        //下面2个
        if (column + index >= 0 && 
            column + index < maxColumns)
            arr.push([row + 1, column + index]);
        if (column >= 0 && column < maxColumns)
            arr.push([row + 1, column]);
        return arr;
    }
    
    /**
     * 新建一个空行
     */
    private function addNewRow():void
    {
        this.rows++;
        var maxColumns:int;
        if (this.rows % 2 == 1) maxColumns = this.columns - 1; //双数行
        else maxColumns = this.columns; //单数行
        this.bubbleList[this.rows - 1] = [];
        for (var column:int = 0; column < maxColumns; column += 1)
        {
            this.bubbleList[this.rows - 1][column] = null;
        }
    }
    
    //***********public function***********
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
        if (!this.bubbleDict || !this.shotBubbleList) return;
        var bVo:BubbleVo = new BubbleVo();
        bVo.x = x;
        bVo.y = y;
        bVo.vx = vx;
        bVo.vy = vy;
        bVo.color = color;
        bVo.radius = 30;
        bVo.isCheck = false;
        this.drawBubble(bVo);
        this.bubbleDict[bVo] = bVo;
        this.shotBubbleList.push(bVo);
    }
    
    /**
     * 更新数据
     */
    public function update():void
    {
        if (!this.bubbleDict) return;
        var bVo:BubbleVo;
        for each (bVo in this.bubbleDict) 
        {
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
        if (!this.bubbleDict) return;
        var bVo:BubbleVo;
        for each (bVo in this.bubbleDict) 
        {
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
        for each (bVo in this.bubbleDict)
        {
            if (bVo.display && 
                bVo.display.parent)
                bVo.display.parent.removeChild(bVo.display);
            bVo.display = null;
        }
        this.bubbleList = null;
        this.shotBubbleList = null;
        this.bubbleDict = null;
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