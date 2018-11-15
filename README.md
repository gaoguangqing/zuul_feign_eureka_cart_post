# zuul_feign_eureka_cart_post
SpringCloud使用zuul,feign,eureka整合购物车,post提交版

如果你要在zuul中访问静态页面,

如用下面的url

http://localhost:8050/cartlist.html

请在zuul的application.yml加上
```
  resources:
    static-locations: classpath:/statis/
```
完整版
```
server:
  port: 8050
spring:
  application:
    name: gateway-zuul
  resources:
    static-locations: classpath:/statis/
eureka:
  client:
    serviceUrl:
      defaultZone: http://user:password@localhost:8761/eureka
zuul:
  routes:
    app-zuul:
      path: /shop/**
      serviceId: cart-consumer
```
启动所有的服务后，在Eureka注册中心会看到如下的几个服务http://localhost:8761/
![Eureka注册中心](https://github.com/gaoguangqing/zuul_feign_eureka_cart_post/blob/master/eureka.png)
购车列表页http://localhost:8050/cartlist.html
![Eureka注册中心](https://github.com/gaoguangqing/zuul_feign_eureka_cart_post/blob/master/cartlist.png)
添加到购物车页http://localhost:8050/cartadd.html
![Eureka注册中心](https://github.com/gaoguangqing/zuul_feign_eureka_cart_post/blob/master/cartadd.png)
修改数量页http://localhost:8050/cartmodify.html
![Eureka注册中心](https://github.com/gaoguangqing/zuul_feign_eureka_cart_post/blob/master/cartmodify.png)
删除购物车页http://localhost:8050/cartdelete.html
![Eureka注册中心](https://github.com/gaoguangqing/zuul_feign_eureka_cart_post/blob/master/cartdelete.png)
生产者的controller
```
package com.spoon.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spoon.comm.vo.SysResult;
import com.spoon.feign.CartFeign;
import com.spoon.pojo.Cart;
@RestController
public class CartController {
	@Autowired
	CartFeign cartFeign;
	@RequestMapping("/cart/query/{userId}")
	public SysResult query(@PathVariable("userId") Long userId){
		return cartFeign.query(userId);
	}
	@RequestMapping("/cart/delete/{userId}/{itemId}")
	public SysResult delete(@PathVariable("userId")Long userId,@PathVariable("itemId")Long itemId)
	{
		return cartFeign.delete(userId, itemId);
	}
	@RequestMapping("/cart/update")
	public SysResult updateNum(Cart cart)
	{
		System.out.println(cart.getNum()+" "+cart.getUserId()+" "+cart.getItemId());
		return cartFeign.updateNum(cart);
	}
	@RequestMapping("/cart/save") //以post请求来访问
	public SysResult save(Cart cart)
	{
		return cartFeign.save(cart);
	}
}
```
如果如上面的代码构造生产者Controller那么就可以用post提交保存购物车或者修改数量,那么前端的ajax可以向下面这么写
添加购物车
```
function addCart(){
		var params = {
				userId : $("#userId").text(),
				itemId : $("#itemId").val(),
				itemTitle : $("#itemTitle").val(),
				itemImage : $("#itemImage").val(),
				itemPrice : $("#itemPrice").val(),
				num : $("#num").val()
			};
			$.post("/shop/cart/save", params, function(result) {
				if (result.status=="200") {
					if (result.msg=="OK"){
						alert("新增购物车成功");
						window.location.href="cartlist.html";
					}
				} else if(result.status=="202"){
					console.log(result);
					alert(result.msg);
					window.location.href="cartlist.html";
				}else{
					alert("新增商品失败");
					window.location.href="cartlist.html";
				}
			});
	}
```
修改数量
```
function updateCart(){
		var params = {
				userId : $("#userId").text(),
				itemId : $("#itemId").val(),
				num : $("#num").val()
			};
			$.post("/shop/cart/update", params, function(result) {
				if (result.status=="200") {
					if (result.msg=="OK"){
						alert("修改成功");
						window.location.href="cartlist.html";
					}
				}else{
					alert("修改失败");
					window.location.href="cartlist.html";
				}
			});
	}
```
生产者的feign接口,用对象接受参数，要加上@RequestBody 
```
package com.spoon.feign;


import org.springframework.cloud.netflix.feign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.spoon.comm.vo.SysResult;
import com.spoon.pojo.Cart;

@FeignClient("cart-provider")
public interface CartFeign {
	@RequestMapping("/cart/query/{userId}")
	public SysResult query(@PathVariable("userId") Long userId) ;
	@RequestMapping("/cart/delete/{userId}/{itemId}")
	public SysResult delete(@PathVariable("userId")Long userId,@PathVariable("itemId")Long itemId) ;
	@RequestMapping("/cart/update")
	public SysResult updateNum(@RequestBody Cart cart) ;
	@RequestMapping("/cart/save") //以post请求来访问
	public SysResult save(@RequestBody Cart cart);
}
```
消费者的controller
```
package com.spoon.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spoon.comm.vo.SysResult;
import com.spoon.pojo.Cart;
import com.spoon.service.CartService;

@RestController
public class CartController {
	@Autowired
	private CartService cartService;
	
	@RequestMapping("/cart/query/{userId}")
	public SysResult query(@PathVariable("userId") Long userId) {
		try {
			System.out.println("CartController.query()"+userId);
			System.out.println("CartController.query()"+cartService);
			List<Cart> cartList = cartService.query(userId);
			return SysResult.oK(cartList);
		} catch (Exception e) {
			e.printStackTrace();
			return SysResult.build(201, "查询购物车失败");
		}
	}
	@RequestMapping("/cart/delete/{userId}/{itemId}")
	public SysResult delete(@PathVariable("userId")Long userId,@PathVariable("itemId")Long itemId) {
		try {
			cartService.delete(userId, itemId);
			return SysResult.oK();
		} catch (Exception e) {
			e.printStackTrace();
			return SysResult.build(201, "删除商品出错");
		}
		
	}
	@RequestMapping("/cart/update")
	public SysResult updateNum(@RequestBody Cart cart) {
		try {
			cartService.updateNum(cart);
			return SysResult.oK();
		} catch (Exception e) {
			e.printStackTrace();
			return SysResult.build(201, "修改商品数量出错");
		}
	}
	@RequestMapping("/cart/save") //以post请求来访问
	public SysResult save(@RequestBody Cart cart) {
		return cartService.save(cart);
	}
}
```
zuul的回调配置
```
package com.spoon.fallback;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.springframework.cloud.netflix.zuul.filters.route.ZuulFallbackProvider;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
@Component //包扫描
public class ZuulFallback implements ZuulFallbackProvider{

	@Override	//获取路由，application.name
	public String getRoute() {
		return "*";
	}

	@Override	//设置返回值，通常用json体现，utf-8防止中文乱码
	public ClientHttpResponse fallbackResponse() {
		return new ClientHttpResponse() {
			
			@Override	//请求响应头信息，contentType和字符类型
			public HttpHeaders getHeaders() {
				//返回类型为json,字符集为u8
				HttpHeaders header = new HttpHeaders();
				header.setContentType(MediaType.APPLICATION_JSON_UTF8);
				return header;
			}
			
			@Override	//响应体，具体返回内容
			public InputStream getBody() throws IOException {
				String returnValue = "默认购物车";	//返回默认值
				return new ByteArrayInputStream(returnValue.getBytes());
			}
			
			@Override	//返回文字描述
			public String getStatusText() throws IOException {
				return HttpStatus.BAD_REQUEST.getReasonPhrase();
			}
			
			@Override	//返回状态码
			public HttpStatus getStatusCode() throws IOException {
				return HttpStatus.BAD_REQUEST;
			}
			
			@Override	//返回二进制状态码
			public int getRawStatusCode() throws IOException {
				// TODO Auto-generated method stub
				return 0;
			}
			
			@Override	//关闭释放资源
			public void close() {
				// TODO Auto-generated method stub
				
			}
		};
	}

}

```
