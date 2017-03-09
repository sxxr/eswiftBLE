//
//  ServiceViewController.swift
//  eswiftBLE
//
//  Created by 　mac on 2017/3/8.
//  Copyright © 2017年 Razil. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceViewController: UIViewController,UITextFieldDelegate,CBCentralManagerDelegate, CBPeripheralDelegate{
    
    /************************ 类变量 *********************/
    //控件
    @IBOutlet weak var trTextConnectState: UILabel!
    @IBOutlet weak var trTextDeviceName: UILabel!
    @IBOutlet weak var trTextInfo: UITextView!
    @IBOutlet weak var trTextDataRead: UITextView!
    @IBOutlet weak var trTextDataWrite: UITextField!

    //属性
    var trFlagLastConnectState : Bool! = false
    //容器，保存搜索到的蓝牙设备
    var PeripheralToConncet : CBPeripheral!
    var trPeripheralManger : CBPeripheralManager!
    var trCBCentralManager : CBCentralManager!
    var trCharactisics : NSMutableArray = NSMutableArray() //初始化用于储存Charactisic
    var trServices : NSMutableArray = NSMutableArray() //初始化动态数组用于储存Service
    
    /************************ 系统函数 *********************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = PeripheralToConncet.name {
            self.navigationItem.title = name
        }
        
        switch PeripheralToConncet.state {
        case CBPeripheralState.connected:
            NSLog("已连接")
            trTextConnectState.text = "已连接"
            trTextConnectState.textColor = UIColor.green
            trFlagLastConnectState = true
        case CBPeripheralState.disconnected:
            NSLog("未连接")
            trTextConnectState.text = "未连接"
            trTextConnectState.textColor = UIColor.green
            if !trFlagLastConnectState {
                NSLog("设备\(PeripheralToConncet.name!)已断开连接")
                trFlagLastConnectState = false
            }
        default:
            NSLog("状态错误")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(<#T##animated: Bool##Bool#>)
        trCBCentralManager.cancelPeripheralConnection(PeripheralToConncet) //页面关闭时断开连接
    }
    
    /****************** 控件响应 *********************/
    @IBAction func trWriteData(_ sender: Any) {
    }
    @IBAction func trEnterData(_ sender: Any) {
    }
    //点击“重新连接”响应函数
    @IBAction func trReconnect(_ sender: Any) {
        NSLog("重新连接\(PeripheralToConncet.name!)")
        if PeripheralToConncet.state == CBPeripheralState.disconnected{
             trCBCentralManager.connect(PeripheralToConncet, options: nil)
        }

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //输入完成 键盘消失
        trTextDataWrite.resignFirstResponder()
        return true
    }
    //点击屏幕其他位置可以关闭键盘
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trTextDataWrite.resignFirstResponder() //关闭数字键盘
    }
    //向下滑动关闭键盘
    @IBAction func trPan(_ sender: Any) {
        trTextDataWrite.resignFirstResponder()
    }
    /****************  蓝牙函数委托响应   ***************/
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state{
            case CBManagerState.poweredOn:  //蓝牙已打开正常
                NSLog("启动成功，开始搜索")
            case CBManagerState.unauthorized: //无BLE权限
                NSLog("无BLE权限")
            case CBManagerState.poweredOff: //蓝牙未打开
                NSLog("蓝牙未开启")
            default:
                NSLog("状态无变化")
        }
    }

    
    //链接成功，相应函数
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //停止搜索并发现服务
        NSLog("正在连接")
        self.PeripheralToConncet! = peripheral
        self.PeripheralToConncet.delegate = self //绑定外设
        self.PeripheralToConncet.discoverServices(nil)//搜索服务
        NSLog("重新连接上设备\(peripheral.name)")
    }
    
    //链接失败，响应函数
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("连接\(peripheral.name)失败 ， 错误原因: \(error)")
    }
    
    //搜索到服务，开始搜索Charactisic
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
       NSLog("搜索到\(peripheral.services?.count)个服务")
    }
    
    //搜索到Charactistic
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        NSLog("从服务\(service.description) 搜索到\(service.characteristics?.count)个服务")
    }

}
