package dialogs
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.net.dns.AAAARecord;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import UI.MyButton;
	import UI.MyText;
	
	import data.DataPool;
	import data.GameInit;
	import data.TcpSocket;
	
	import event.CommEvent;

	public class UserLogin extends DialogObject
	{
		private var uinput:TextField;
		private var pinput:TextField;
		private var socket:Socket;
		public function UserLogin()
		{
			init();
		}
		private function init():void{
			this.visible = true;
			theTitle("登 陆");
			this.graphics.beginFill(0Xcccc77);
			this.graphics.drawRect(0,0,GameInit.m_stage.stageWidth,GameInit.m_stage.stageHeight);
			
			var spr:Sprite = new Sprite;
			spr.x = 80;
			spr.y = 200;
			this.addChild(spr);
			var utxt:MyText = new MyText("用户名：");
			var ptxt:MyText = new MyText("密　码：");
			ptxt.y = 60;
			spr.addChild(utxt);
			spr.addChild(ptxt);
			

			
			var my_fmt:TextFormat = new TextFormat();//常用样式
			my_fmt.size = 20;
			my_fmt.font = "微软雅黑";
			
			uinput = new TextField();
			uinput.type = TextFieldType.INPUT;
			uinput.x = utxt.width + utxt.x;
			uinput.width = 200;
			uinput.height = 28;
			uinput.text = "root";
			uinput.defaultTextFormat = my_fmt;
			spr.addChild(uinput);
			pinput = new TextField();
			pinput.type = TextFieldType.INPUT;
			pinput.x = utxt.width + utxt.x;
			pinput.y = 60;
			pinput.width = 200;
			pinput.height = 28;
			pinput.text = "123";
			pinput.displayAsPassword = true;
			pinput.defaultTextFormat = my_fmt;
			spr.addChild(pinput);
			
			spr.graphics.lineStyle(1,0x000000);
			spr.graphics.beginFill(0Xcccc77);
			spr.graphics.drawRect(utxt.width + utxt.x ,0,200,uinput.height);
			spr.graphics.drawRect(utxt.width + utxt.x ,60,200,uinput.height);
			
			var login:MyButton = new MyButton("登 陆",0xccaa77,70);
			login.x = 140;
			login.y = 360;
			login.addEventListener(MouseEvent.CLICK,loginHandler);
			this.addChild(login);
			var regist:MyButton = new MyButton("注 册",0xccaa77,70);
			regist.x = 250;
			regist.y = 360;
			regist.addEventListener(MouseEvent.CLICK,loginHandler);
			this.addChild(regist);
			
//			socket = new Socket;
//			socket.addEventListener(Event.CONNECT,onConnect);
//			socket.connect("192.168.0.38",8101);
			TcpSocket.getMe().registerBackFun(10003,loginOK);
			//TcpSocket.getMe().registerBackFun(10010,bagOK);
			TcpSocket.getMe().connect("192.168.0.38",8101);
		}
		private function loginHandler(e:MouseEvent):void{	
			var byte:ByteArray = new ByteArray;
			byte.writeUnsignedInt(getRealLen(uinput.text+pinput.text));
			byte.writeInt(10001);
			byte.writeUTF(uinput.text);
			byte.writeUTF(pinput.text);
			TcpSocket.getMe().sendData(10001,byte,loginOK);
			
			//TcpSocket.getMe().registerBackFun(10004,loginSuc);
		}
		private function registHandler(e:MouseEvent):void{
			
		}
		private function loginOK(e:ByteArray):void{
			var head:int = e.readShort();
			var msg:String = e.readUTF();
			var arr:Array = msg.split(",");
			
			var obj:Object = new Object;
			for (var i:int =0;i<arr.length;i++){
				var ta:Array = arr[i].split(":");				
				obj[ta[0]] = ta[1];				
			}
			DataPool.getArr("user").push(obj);
			this.visible = false;
			var evt:CommEvent = new CommEvent(CommEvent.LOGIN);
			dispatchEvent(evt);
		}
		private function bagOK(e:ByteArray):void{
			var head:int = e.readShort();
			var msg:Object = e.readObject();
			
			var arr:Array = msg.split(",");
			
			var obj:Object = new Object;
			for (var i:int =0;i<arr.length;i++){
				var ta:Array = arr[i].split(":");				
				obj[ta[0]] = ta[1];				
			}
			DataPool.getArr("bag").push(obj);
			this.visible = false;
			var evt:CommEvent = new CommEvent(CommEvent.LOGIN);
			dispatchEvent(evt);
		}
		public function getRealLen(msg:String):int
		{
			var byte:ByteArray = new ByteArray;
			byte.writeUTF(msg);
			byte.position = 0;
			return (byte.length+5);
		}

	}
}