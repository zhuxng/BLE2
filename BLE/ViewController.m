//
//  ViewController.m
//  BLE
//
//  Created by 朱星 on 2016/11/21.
//  Copyright © 2016年 朱星. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong)CBCentralManager *mgr;
@property (nonatomic, strong)CBPeripheral *perpheral;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mgr = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    

}
#pragma mark - 中心管家代理

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn) {
        //开始扫描
        [self.mgr scanForPeripheralsWithServices:nil options:nil];
    }
    
}
//发现外部设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{

    NSLog(@"perpheral = %@", self.perpheral);
    _perpheral = peripheral;
    self.perpheral.delegate = self;
    [self.mgr connectPeripheral:peripheral options:nil];
}

// 链接外部设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connect = %@",self.perpheral);
    [self.perpheral discoverServices:nil];
    
}


-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"services = %@", peripheral.services);
    for (CBService *services in peripheral.services) {
        if ([services.UUID.UUIDString isEqualToString:@"FEE7"]) {
            [self.perpheral discoverCharacteristics:nil forService:services];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"characteristics = %@",service.characteristics);
    /*
     "<CBCharacteristic: 0x1740becc0, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>",
     "<CBCharacteristic: 0x1742a0d80, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>"
     )
     
     Manufacturer: 制作商
     properties ：  属性
     
     */
    
    for (CBCharacteristic *cb in service.characteristics) {
        
        [self.perpheral discoverDescriptorsForCharacteristic:cb];
        [self.perpheral readValueForCharacteristic:cb];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"description = %@",characteristic.description);
    /*
     description = <CBCharacteristic: 0x1740ac660, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>
     */
    
    for (CBDescriptor *dp in characteristic.descriptors) {
        [self.perpheral readValueForDescriptor:dp];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
