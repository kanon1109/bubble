package  
{
import data.BubbleVo;
import event.BubbleEvent;
import flash.display.DisplayObjectContainer;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import utils.MathUtil;
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
    //存放下落泡泡字典
    private var fallBubbleDict:Dictionary;
    //待销毁的泡泡列表
    private var bubbleCloseAry:Array;
    //待保留的泡泡列表
    private var retainBubbleList:Array;
    //列数
    private var columns:int;
    //行数
    private var _rows:int;
	//当前泡泡的数量
    private var _bubbleNum:int;
    //半径
    private var radius:Number;
    //碰撞检测范围
    private var hitRange:Number;
    //移动范围
    private var _range:Rectangle;
    //射出的泡泡列表
    private var shotBubbleVo:BubbleVo;
	//更新泡泡数据事件
	private var updateBubbleEvent:BubbleEvent;
    //销毁泡泡显示事件
	private var removeBubbleEvent:BubbleEvent;
    //最小链接长度
    private var minLinkNum:int;
	//起始类型是靠右还是靠左 false为左 用于添加第一行时计算定位使用。
	private var startType:Boolean;
    public function Bubble(columns:int, 
						   radius:Number, 
                           minLinkNum:int = 3)
    {
        this._rows = 0;
        this.columns = columns;
        this.radius = radius;
        this.minLinkNum = minLinkNum;
        this.hitRange = radius * 2 - 5;
        this.initData();
        this.initEvent();
    }
	
	/**
	 * 初始化事件
	 */
	private function initEvent():void 
	{
		this.updateBubbleEvent = new BubbleEvent(BubbleEvent.UPDATE);
		this.removeBubbleEvent = new BubbleEvent(BubbleEvent.REMOVE_BUBBLE);
	}
    
    /**
     * 初始化地图数据
     */
    private function initData():void
    {
        this.bubbleList = [];
        this.bubbleCloseAry = [];
        this.bubbleDict = new Dictionary();
        this.fallBubbleDict = new Dictionary();
        this.shotBubbleVo = null;
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
		//根据起始位置类型判断单双行泡泡的位置
		var num:int;
		if (!this.startType) num = 0;
		else num = 1;
        if (row % 2 == num) startX = this.radius; //单数行
        else startX = this.radius * 2; //双数行 起始位置向前移动一个半径距离
        //行间距
        var dis:Number = this.radius - this.radius * Math.cos(MathUtil.dgs2rds(45));
        return new Point(startX + column * this.radius * 2, startY + (row * this.radius * 2 - row * dis))
    }
    
    /**
     * 碰撞检测
     * @param	bVo    泡泡数据
     */
    private function hitTest(bVo:BubbleVo):void
    {
        if (!this.shotBubbleVo) return;
        if (this.shotBubbleVo != bVo)
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
                //清空待销毁的列表
                this.clearBubbleCloseDict();
                //消除悬空
                this.removeFloating();
                //销毁发射的泡泡
                this.shotBubbleVo = null;
                //发送更新事件
                this.dispatchEvent(this.updateBubbleEvent);
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
			if (bVo && bVo.color == shotBVo.color && !bVo.isCheck)
			{
                bVo.isCheck = true;
                this.bubbleCloseAry.push(bVo);
				this.checkColorType(bVo);
			}
		}
	}
    
    /**
     * 清空待销毁的列表
     */
    private function clearBubbleCloseDict():void
    {
        if (!this.bubbleCloseAry) return;
        var bVo:BubbleVo;
        var length:int = this.bubbleCloseAry.length;
        for (var i:int = length - 1; i >= 0; i -= 1) 
        {
            bVo = this.bubbleCloseAry[i];
            bVo.isCheck = false;
            if (length >= this.minLinkNum)
            {
                this.removeBubble(bVo);
                this.removeBubbleEvent.bVo = bVo;
                this.dispatchEvent(this.removeBubbleEvent);
            }
            this.bubbleCloseAry.splice(i, 1);
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
        var index:int;
        var bVo:BubbleVo;
        if (dir == 0 || dir == 1)
        {
            //左右2个
            if (column - 1 >= 0)
                arr.push([row, column - 1]);
            if (column + 1 < this.columns)
                arr.push([row, column + 1]);
        }
        if (dir == 0 || dir == 2)
        {
            //判断上下两行是单行或双行
			if (!this.startType)
			{
				if ((row - 1) % 2 == 0) index = 1; //单行
				else index = -1; //双行
			}
			else
			{
				if ((row - 1) % 2 == 0) index = -1; //单行
				else index = 1; //双行
			}
            //上面2个
            if (row - 1 >= 0)
            {
                if (column + index >= 0 && 
                    column + index < this.columns)
                    arr.push([row - 1, column + index]);
                if (column >= 0 && 
                    column < this.columns)
                    arr.push([row - 1, column]);
            }
            //下面2个
            if (row + 1 < this._rows)
            {
                if (column + index >= 0 && 
                    column + index < this.columns)
                    arr.push([row + 1, column + index]);
                if (column >= 0 && column < this.columns)
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
        this.bubbleList[this._rows - 1] = [];
        for (var column:int = 0; column < this.columns; column += 1)
        {
            this.bubbleList[this._rows - 1][column] = null;
        }
    }
    
    /**
     * 消除悬空的泡泡
     */
    private function removeFloating():void
    {
        this.retainBubbleList = [];
        var bVo:BubbleVo;
        var arr:Array;
        //循环列数
        for (var column:int = 0; column < this.columns; column += 1)
        {
            bVo = this.bubbleList[0][column];
            if (bVo && !bVo.isCheck)
            {
                bVo.isCheck = true;
                this.retainBubbleList.push(bVo);
                this.checkRoundBubble(bVo);
            }
        }
        
        //遍历整个泡泡列表，如果不在待保留的列表中则销毁并且放入下落列表中。
        var retainBubbleVo:BubbleVo;
        var length:int = this.retainBubbleList.length;
		for each (bVo in this.bubbleDict) 
		{
			for (var i:int = 0; i < length; i += 1) 
			{
				retainBubbleVo = this.retainBubbleList[i];
				if (bVo.row == retainBubbleVo.row && 
					bVo.column == retainBubbleVo.column)
				{
					bVo.isCheck = false;
					break;
				}
			}
			//如果不在保留列表中则设置重力。
			if (i == length)
			{
				bVo.g = 1;
				this.removeBubble(bVo);
				this.fallBubbleDict[bVo] = bVo;
			}
		}
    }
    
    /**
     * 获取周围泡泡
     * @param	row     行坐标
     * @param	column  列坐标
     * @return  泡泡列表
     */
    private function getRoundBubble(row:int, column:int):Array
    {
        var bubbleAry:Array = [];
        var arr:Array = this.getRoundBubblePos(row, column);
        var length:int = arr.length;
        var roundVo:BubbleVo;
        var roundRow:int;
        var roundColumn:int;
        for (var i:int = 0; i < length; i += 1) 
        {
            roundRow = arr[i][0];
            roundColumn = arr[i][1];
            roundVo = this.bubbleList[roundRow][roundColumn];
            if (roundVo) bubbleAry.push(roundVo);
        }
        return bubbleAry;
    }
    
    /**
     * 判断周围的是否泡泡，并且把泡泡数据放入列表中
     * @param	bVo     当前泡泡数据
     */
    private function checkRoundBubble(bVo:BubbleVo):void
    {
        if (!bVo) return;
        var arr:Array = this.getRoundBubble(bVo.row, bVo.column);
        if (arr.length == 0) return;
        var length:int = arr.length;
        var roundVo:BubbleVo;
        for (var i:int = 0; i < length; i += 1) 
        {
            roundVo = arr[i];
            //如果判断过则不再进行判断
            if (!roundVo.isCheck)
            {
                roundVo.isCheck = true;
                this.retainBubbleList.push(roundVo);
                this.checkRoundBubble(roundVo);
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
			if (this.shotBubbleVo.y <= this.radius && Math.abs(this.shotBubbleVo.x - point.x) <= this.radius)
            {
                bVo = this.bubbleList[0][column];
                if (!bVo)
                {
                    //添加一个泡泡数据
                    this.pushBubble(this.shotBubbleVo, 0, column, point.x, point.y);
                    //判断颜色类型
                    this.checkColorType(this.shotBubbleVo);
                    //清空待销毁的列表
                    this.clearBubbleCloseDict();
                    //销毁发射的泡泡
                    this.shotBubbleVo = null;
                    //消除悬空
                    this.removeFloating();
                    this.dispatchEvent(this.updateBubbleEvent);
                    return;
                }
            }
        }
		//防止穿透bug
		if (this.shotBubbleVo.y < this._range.top - this.shotBubbleVo.radius)
		{
			delete this.bubbleDict[this.shotBubbleVo];
			this.removeBubbleEvent.bVo = this.shotBubbleVo;
			this.dispatchEvent(this.removeBubbleEvent);
			this.shotBubbleVo = null;
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
    
    /**
     * 泡泡下落
     * @param	rect   下落最大范围
     */
    private function bubbleFalling(rect:Rectangle):void
    {
        if (!this.fallBubbleDict) return;
        var bVo:BubbleVo;
        for each (bVo in this.fallBubbleDict) 
        {
            bVo.vy += bVo.g;
            bVo.y += bVo.vy;
            if (bVo.y >= rect.bottom)
            {
                bVo.g = 0;
                delete this.fallBubbleDict[bVo];
                this.removeBubbleEvent.bVo = bVo;
                this.dispatchEvent(this.removeBubbleEvent);
            }
        }
    }
    
    //***********public function***********
    /**
     * 获取泡泡数据列表
     * @return  泡泡数据列表
     */
    public function getBubbleList():Array
    {
        if (!this.bubbleDict) return null;
        var arr:Array = [];
        var bVo:BubbleVo;
        for each (bVo in this.bubbleDict) 
        {
            arr.push(bVo);
        }
        //将下落的泡泡放入列表
        if (!this.fallBubbleDict) return null;
        for each(bVo in this.fallBubbleDict) 
        {
            arr.push(bVo);
        }
        return arr;
    }
    
    /**
     * 发射一个泡泡
     * @param	x           起始x位置
     * @param	y           起始y位置
     * @param	vx          x向量
     * @param	vy          y向量
     * @param	color       颜色
     * @return  被发射的泡泡数据
     */
    public function shotBubble(x:Number, y:Number, 
                               vx:Number, vy:Number, 
                               color:uint):BubbleVo
    {
        if (!this.bubbleDict || this.shotBubbleVo) return null;
        this.shotBubbleVo = new BubbleVo();
        this.shotBubbleVo.x = x;
        this.shotBubbleVo.y = y;
        this.shotBubbleVo.vx = vx;
        this.shotBubbleVo.vy = vy;
        this.shotBubbleVo.color = color;
        this.shotBubbleVo.radius = 30;
        this.bubbleDict[this.shotBubbleVo] = this.shotBubbleVo;
        return this.shotBubbleVo;
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
        this.bubbleFalling(this.range);
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
	 * 增加一个新行
	 * @param	colorAry		颜色数组
	 */
	public function addLine(colorAry:Array):Array
	{
		this.startType = !this.startType;
		this.addNewEmptyRow();
		var bVo:BubbleVo;
		var point:Point;
		var column:int;
		for (var row:int = this._rows - 1; row >= 0; row -= 1)
        {
            //循环列数
            for (column = 0; column < this.columns; column += 1)
            {
				bVo = this.bubbleList[row][column];
				if (bVo)
				{
					bVo.row = row + 1;
					point = this.getBubblePos(row + 1, column);
					bVo.y = point.y;
					this.bubbleList[row + 1][column] = bVo;
					this.bubbleList[row][column] = null;
				}
			}
		}
		
		var length:int;
		if (colorAry.length < this.columns)
		{
			//如果长度不足则自动补足
			length = this.columns - colorAry.length;
			for (var i:int = 0; i < length; i += 1)
			{
				colorAry.concat(colorAry[colorAry.length - 1]);
			}
		}
		else if (colorAry.length > this.columns)
		{
			//如果长度超过则删除多余
			length = colorAry.length - this.columns;
			colorAry.splice(this.columns - 1, length);
		}
		
		var arr:Array = [];
		for (column = 0; column < this.columns; column += 1)
		{
			bVo = new BubbleVo();
			bVo.color = colorAry[column];
			bVo.radius = this.radius;
			point = this.getBubblePos(0, column);
			this.pushBubble(bVo, 0, column, point.x, point.y);
			this.bubbleDict[bVo] = bVo;
			this.dispatchEvent(this.updateBubbleEvent);
			arr.push(bVo);
		}
		return arr;
	}
	
    /**
     * 销毁
     */
    public function destroy():void
    {
        var bVo:BubbleVo;
        for each (bVo in this.bubbleDict)
        {
            bVo.vx = 0;
            bVo.vy = 0;
            bVo.g = 0;
            delete this.bubbleDict[bVo];
        }
        this.bubbleList = null;
        this.retainBubbleList = null;
        this.shotBubbleVo = null;
        this.bubbleDict = null;
        this.bubbleCloseAry = null;
        this.range = null;
        this.fallBubbleDict = null;
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