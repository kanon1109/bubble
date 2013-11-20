package utils
{
public class Random
{
    
    /**
     * 在 start 与 stop之间取一个随机整数，可以用step指定间隔， 但不包括较大的端点（start与stop较大的一个）
     * 如 
     * Random.randrange(1, 10, 3) 
     * 则返回的可能是   1 或  4 或  7  , 注意 这里面不会返回10，因为是10是大端点
     * 
     * @param start
     * @param stop
     * @param step
     * @return 假设 start < stop,  [start, stop) 区间内的随机整数
     * 
     */
    public static function randrange(start:int, stop:int, step:uint=1):int
    {
        if (step == 0)
            throw new Error('step 不能为 0');
            
        var width:int = stop - start;
        if (width == 0)
            throw new Error('没有可用的范围('+ start + ',' + stop+')');
        if (width < 0)
            width = start - stop;
            
        var n:int = int((width + step - 1) / step);
        return int(random() * n) * step + Math.min(start, stop);
    }
    
    /**
     * 返回a 到 b直间的随机整数，包括 a 和 b
     * @param a
     * @param b
     * @return [a, b] 直接的随机整数
     * 
     */
    public static function randint(a:int, b:int):int
    {
        if (a > b)
            a++;
        else
            b++;
        return randrange(a, b);
    }
    
    /**
     * 返回 a - b之间的随机数，不包括  Math.max(a, b)
     * @param a
     * @param b
     * @return 假设 a < b, [a, b)
     * 
     */
    public static function randnum(a:Number, b:Number):Number
    {
        return random() * (b - a) + a;
    }
    
    /**
     * 打乱数组
     * @param array
     * @return 
     * 
     */
    public static function shuffle(array:Array):Array
    {
        array.sort(_randomCompare);
        return array;
    }
    
    public static function _randomCompare(a:Object, b:Object):int
    {
        return (random() > .5) ? 1 : -1;
    }
    
    /**
     * 从序列中随机取一个元素
     * @param sequence 可以是 数组、 vector，等只要是有length属性，并且可以用数字索引获取元素的对象，
     *                 另外，字符串也是允许的。
     * @return 序列中的某一个元素 
     * 
     */
    public static function choice(sequence:Object):*
    {
        if (!sequence.hasOwnProperty('length'))
            throw new Error('无法对此对象执行此操作');
            
        var index:int = int(random() * sequence.length);
        if (sequence is String)
            return String(sequence).charAt(index);
        else
            return sequence[index];
    }
    
    /**
     * 对列表中的元素进行随机采样
     * <pre>
     * Random.sample([1, 2, 3, 4, 5],  3)  // Choose 3 elements
     * [4, 1, 5]
     * </pre>
     * @param sequence
     * @param num
     * @return 
     * 
     */
    public static function sample(sequence:Object, num:uint):Array
    {
        if (!sequence.hasOwnProperty('length'))
            throw new Error('无法对此对象执行此操作');
        
        var len:int = sequence.length;
        if (num <= 0 || len < num)
            throw new Error('采样数量不够');
            
        var selected:Array = [];
        var indices:Array = [];
        for (var i:Number = 0; i < num; i++)
        {
            var index:int = int(random() * len);
            while (indices.indexOf(index) >= 0)
                index = int(random() * len);
            
            selected.push(sequence[index]);
            indices.push(index);
        }
        
        return selected;
    }
    
    /**
     * 返回 0.0 - 1.0 之间的随机数，等同于 Math.random()
     * @return Math.random()
     * 
     */
    public static function random():Number
    {
        return Math.random();
    }
	
	/**
	 * 计算概率
	 * @param	chance 概率
	 * @return
	 */
	public static function boolean(chance:Number = .5):Boolean
	{
		return (Random.random() < chance) ? true:false;
	}
    
}
}