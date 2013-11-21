package  
{
import data.BubbleVo;
import event.BubbleEvent;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import utils.MathUtil;
import utils.Random;
/**
 * ...泡泡龙算法
 * @author Kanon
 */
public class Bubble extends EventDispatcher
{
    //泡泡数据列表
    private var bubbleList:Array;
    //泡泡字典用于快速遍历泡泡并且让其移动
    private var bubbleDict:Dictionary;
    //列数
    private var columns:int;
    //行数
    private var _rows:int;
	//当前泡泡的数量
    private var _bubbleNum:int;
    //半径
    private var radius:Number;
	//颜色种类
    private var colorType:uint;
    //碰撞检测范围
    private var hitRange:Number;
    //外部容器
    private var stage:DisplayObjectContainer;
    //移动范围
    private var _range:Rectangle;
    //射出的泡泡列表
    private var shotBubbleVo:BubbleVo;
	//泡泡龙事件
	private var bubbleEvent:BubbleEvent;
    public function Bubble(stage:DisplayObjectContainer, 
                           rows:int, columns:int, 
						   radius:Number, colorType:int)
    {
        this.stage = stage;
        this._rows = rows;
        this.columns = columns;
        this.radius = radius;
        this.colorType = colorType;
        this.hitRange = radius * 2 - 5;
        this.initData();
        this.initDraw();
        this.initEvent();
    }
	
	/**
	 * 初始化事件
	 */
	private function initEvent():void 
	{
		this.bubbleEvent = new BubbleEvent(BubbleEvent.UPDATE);
	}
    
    /**
     * 初始化地图数据
     */
    private function initData():void
    {
        this.bubbleList = [];
        this.bubbleDict = new Dictionary();
        this.shotBubbleVo = null;
        var bVo:BubbleVo;
        //最大列数
        var maxColumns:int;
        var point:Point;
        //偶数行的数量
        var evenRowNum:int = this._rows % 2 == 0 ? this._rows / 2 : (this._rows + 1) / 2 - 1;
        var num:int = this._rows * this.columns - evenRowNum;
		this._bubbleNum = num;
        //循环行数
        for (var row:int = 0; row < this._rows; row += 1)
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
                    bVo.color = Random.randint(1, this.colorType);
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
		var color:Array = [null, 0xFF00FF, 0xFFFF00, 0x0000FF, 0xCCFF00, 0x00CCFF];
        bVo.display = new Sprite();
        Sprite(bVo.display).graphics.lineStyle(1, 0);
        Sprite(bVo.display).graphics.beginFill(color[bVo.color]);
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
        if (!this.shotBubbleVo) return;
        if (this.shotBubbleVo != bVo && !bVo.isRemove)
        {
            if (MathUtil.distance(this.shotBubbleVo.x, this.shotBubbleVo.y, bVo.x, bVo.y) <= this.hitRange)
            {
                //如果行数超过最大行则添加一个新的空行
                if (bVo.row + 1 >= this._rows) this.addNewEmptyRow();
                var posAry:Array = this.getRoundBubblePos(bVo.row, bVo.column);
                //自动吸附
                this.autoAbsorption(this.shotBubbleVo, posAry);
                //判断颜色类型
                this.checkColorType(this.shotBubbleVo);
                //消除悬空
                this.removeFloating();
                //销毁发射的泡泡
                this.shotBubbleVo = null;
                //发送更新事件
                this.dispatchEvent(this.bubbleEvent);
            }
        }
    }
    
    /**
     * 自动吸附
     * @param	shotBVo     发射的泡泡数据
     * @param	posAry      周围几个点的坐标
     */
    private function autoAbsorption(shotBVo:BubbleVo, posAry:Array):void
    {
        //判断是否超过最后一行
        var length:int = posAry.length;
		if (length == 0) return;
        //距离列表
        var disArr:Array = [];
        var point:Point;
        var bVo:BubbleVo;
        var row:int;
        var column:int;
        for (var i:int = 0; i < length; i++) 
        {
            row = posAry[i][0];
            column = posAry[i][1];
            bVo = this.bubbleList[row][column];
            //如果此处没有泡泡数据则计算射出的球到这些点的距离
            if (!bVo) 
            {
                point = this.getBubblePos(row, column);
                //保存所有点到被发射的泡泡的距离
                disArr.push( { "distance": MathUtil.distance(shotBVo.x, shotBVo.y, point.x, point.y), 
                               "index":i, 
                               "point":point } );
            }
        }
        //排序 最小距离在前
        disArr.sortOn("distance", Array.NUMERIC);
        var o:Object = disArr[0];
        i = o.index;
        //添加一个新的泡泡进入bubbleList中
        this.pushBubble(shotBVo, posAry[i][0], posAry[i][1], o.point.x, o.point.y);
    }
    
	/**
	 * 递归发散性判断周围有链接的泡泡的颜色类型
	 * @param	shotBVo		发射出去的泡泡数据
	 */
	private function checkColorType(shotBVo:BubbleVo):void
	{
		var arr:Array = this.getRoundBubblePos(shotBVo.row, shotBVo.column);
		var length:int = arr.length;
		if (length == 0) return;
		var bVo:BubbleVo;
        var row:int;
        var column:int;
		for (var i:int = 0; i < length; i++) 
        {
            row = arr[i][0];
            column = arr[i][1];
            bVo = this.bubbleList[row][column];
			if (bVo && bVo.color == shotBVo.color)
			{
				this.removeBubble(bVo);
				this.checkColorType(bVo);
			}
		}
	}
	
	/**
	 * 销毁泡泡
	 * @param	bVo		泡泡数据
	 */
	private function removeBubble(bVo:BubbleVo):void
	{
		if (!bVo) return;
		this.bubbleList[bVo.row][bVo.column] = null;
		delete this.bubbleDict[bVo];
        this._bubbleNum--;
		if (bVo.display && bVo.display.parent)
			bVo.display.parent.removeChild(bVo.display);
		bVo.display = null;
	}
	
    /**
     * 根据行列获取周围6个泡泡行列
     * @param	row         行数
     * @param	column      列数
     * @param	dir         方向 0:周围6个, 1:左右2个，2:上下2个
     * @return  周围6个泡泡的行列的列表
     */
    private function getRoundBubblePos(row:int, column:int, dir:int = 0):Array
    {
        var arr:Array = [];
        //最大列数
        var maxColumns:int;
        var index:int;
        if (row % 2 == 0) maxColumns = this.columns; //单行
        else maxColumns = this.columns - 1; //双行
        var bVo:BubbleVo;
        if (dir == 0 || dir == 1)
        {
            //左右2个
            if (column - 1 >= 0)
                arr.push([row, column - 1]);
            if (column + 1 < maxColumns)
                arr.push([row, column + 1]);
        }
        if (dir == 0 || dir == 2)
        {
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
            if (row + 1 < this._rows)
            {
                if (column + index >= 0 && 
                    column + index < maxColumns)
                    arr.push([row + 1, column + index]);
                if (column >= 0 && column < maxColumns)
                    arr.push([row + 1, column]);
            }
        }
        return arr;
    }
    
    /**
     * 新建一个空行
     */
    private function addNewEmptyRow():void
    {
        this._rows++;
        var maxColumns:int;
        if (this._rows % 2 == 1) maxColumns = this.columns - 1; //双数行
        else maxColumns = this.columns; //单数行
        this.bubbleList[this._rows - 1] = [];
        for (var column:int = 0; column < maxColumns; column += 1)
        {
            this.bubbleList[this._rows - 1][column] = null;
        }
    }
    
    /**
     * 消除悬空的泡泡
     */
    private function removeFloating():void
    {
        //待销毁的列表
        var closeAry:Array = [];
        var bVo:BubbleVo;
        var maxColumns:int;
        var arr:Array;
        var length:int;
        var roundVo:BubbleVo;
        var row:int;
        var column:int;
        for (var row:int = 0; row < this._rows; row += 1)
        {
            if (row % 2 == 1) maxColumns = this.columns - 1; //双数行
            else maxColumns = this.columns; //单数行
            //循环列数
            for (var column:int = 0; column < maxColumns; column += 1)
            {
                bVo = this.bubbleList[row][column];
                if (bVo && !bVo.isRemove && !bVo.isCheck)
                {
                    bVo.isCheck = true;
                    arr = this.getRoundBubblePos(bVo.row, bVo.column);
                    length = arr.length;
                    //查找周围是否有泡泡数据
                    for (var i:int = 0; i < length; i += 1) 
                    {
                        row = arr[i][0];
                        column = arr[i][1];
                        roundVo = arr[i];
                        roundVo = this.bubbleList[row][column];
                        //如果有则设置状态，下次不再查找。
                        if (roundVo && !roundVo.isCheck)
                        {
                            roundVo.isCheck = true;
                        }
                    }
                }
            }
        }
    }
    
    /**
     * 判断射出去的泡泡的最大范围
     * 用于当最后一排无泡泡时，自动吸附。
     */
    private function checkBubbleShotRange():void
    {
        if (!this.shotBubbleVo) return;
        //循环第一行的坐标
        var point:Point;
        var bVo:BubbleVo;
        for (var column:int = 0; column < this.columns; column += 1) 
        {
            point = this.getBubblePos(0, column);
            if (MathUtil.distance(this.shotBubbleVo.x, this.shotBubbleVo.y, point.x, point.y) <= this.radius)
            {
                bVo = this.bubbleList[0][column];
                if (!bVo)
                {
                    //添加一个泡泡数据
                    this.pushBubble(this.shotBubbleVo, 0, column, point.x, point.y);
                    //判断颜色类型
                    this.checkColorType(this.shotBubbleVo);
                    //销毁发射的泡泡
                    this.shotBubbleVo = null;
                    //消除悬空
                    this.removeFloating();
                    this.dispatchEvent(this.bubbleEvent);
                    break;
                }
            }
        }
    }
    
    /**
     * 添加一个泡泡数据
     * @param	bVo     泡泡数据
     * @param	row     行数
     * @param	column  列数
     * @param	x       x位置
     * @param	y       y位置
     */
    private function pushBubble(bVo:BubbleVo, row:int, column:int, x:Number, y:Number):void
    {
        if (!bVo) return;
        bVo.row = row;
        bVo.column = column;
        bVo.x = x;
        bVo.y = y;
        bVo.vx = 0;
        bVo.vy = 0;
        this.bubbleList[row][column] = bVo;
        this._bubbleNum++;
    }
    
    //***********public function***********
    /**
     * 发射一个泡泡
     * @param	x      起始位置
     * @param	y      起始位置
     * @param	vx          x向量
     * @param	vy          y向量
     * @param	color       颜色
     */
    public function shotBubble(x:Number, y:Number, 
                               vx:Number, vy:Number, 
                               color:uint):void
    {
        if (!this.bubbleDict || this.shotBubbleVo) return;
        this.shotBubbleVo = new BubbleVo();
        this.shotBubbleVo.x = x;
        this.shotBubbleVo.y = y;
        this.shotBubbleVo.vx = vx;
        this.shotBubbleVo.vy = vy;
        this.shotBubbleVo.color = color;
        this.shotBubbleVo.radius = 30;
        this.bubbleDict[this.shotBubbleVo] = this.shotBubbleVo;
        this.drawBubble(this.shotBubbleVo);
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
            bVo.vy += bVo.g;
            this.checkRange(bVo, this.range);
            this.hitTest(bVo);
        }
        this.checkBubbleShotRange();
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
        this.shotBubbleVo = null;
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
    
    /**
     * 当前行数
     */
    public function get rows():int { return _rows; };
	
	/**
	 * 当前泡泡的数量
	 */
	public function get bubbleNum():int{ return _bubbleNum; }
}
}