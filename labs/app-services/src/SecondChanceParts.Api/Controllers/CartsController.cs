using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using SecondChanceParts.Api.Models;

namespace SecondChanceparts.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CartsController : ControllerBase
    {

        private readonly SecondChanceParts.Api.Data.SecondChancePartsContext _context;
        private readonly ILogger<CartsController> _logger;

        public CartsController(SecondChanceParts.Api.Data.SecondChancePartsContext context,ILogger<CartsController> logger)
        {
            _context = context;
            _logger = logger;
        }
        
      
        [HttpGet]
        public async Task<IActionResult> GetCartsAsync(){

            // ShoppingCart = await _context.ShoppingCarts.FirstOrDefaultAsync(m => m.CartId == cartId);
            var shoppingCarts = await _context.ShoppingCarts.ToListAsync();

            return Ok(shoppingCarts);

        }

        [HttpGet]
        [Route("{id}")]
        public async Task<IActionResult> GetCartsAsync(int id){

            var shoppingCart = await _context.ShoppingCarts.FirstOrDefaultAsync(m => m.CartId == id);

            if(shoppingCart == null){
                return NotFound();
            }

            return Ok(shoppingCart);

        }

        [HttpPost]
        [Route("{id}/addtocart")]
        public async Task<IActionResult> AddToCartAsync(int id, [FromBody]ShoppingCartItem item){

            var shoppingCart = await _context.ShoppingCarts.FirstOrDefaultAsync(m => m.CartId == item.ShoppingCartId);

            if(shoppingCart == null){
                return NotFound("Shopping Cart Not Found");
            }

            await _context.ShoppingCartItems.AddAsync(item);
            await _context.SaveChangesAsync();

            return Ok(item);

        }

        [HttpPost]
        [Route("{id}/checkout")]
        public async Task<IActionResult> CheckoutAsync(int id, [FromBody]ShoppingCart cart){


            var ShoppingCart = await _context.ShoppingCarts.FirstOrDefaultAsync(m => m.CartId == cart.CartId);

            if (ShoppingCart == null)
            {
                return NotFound();
            }

            ShoppingCart.CartStatus = "Checked-Out";
            await _context.SaveChangesAsync();

            return Ok(ShoppingCart);

        }

        [HttpGet]
        [Route("{id}/Items")]
        public async Task<IActionResult> GetCartItemsAsync(int id){

            var items = await _context.ShoppingCartItems.Where(c => c.ShoppingCartId == id)
                                                        .Include(p => p.Part)
                                                        .Include(c => c.Cart)
                                                        .ToListAsync();

            if(items == null){
                return NotFound();
            }

            return Ok(items);

        }

    }
}
