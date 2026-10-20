using System;

namespace CateringSystem
{
    // 购物车项模型 (Serializable 方便存入 Session)
    [Serializable]
    public class CartItem
    {
        public int DishId { get; set; }
        public string DishName { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }

        // 计算小计
        public decimal SubTotal
        {
            get { return Price * Quantity; }
        }
    }
}