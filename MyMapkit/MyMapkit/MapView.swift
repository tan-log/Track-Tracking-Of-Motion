//
//  MapView.swift
//  MyMapkit
//
//  Created by tan on 2021/11/26.
//


import SwiftUI
import MapKit

//存储位置信息

class CoordinatePath: ObservableObject {
    @Published var coordinates: [CLLocationCoordinate2D] = []
}

/* MKMapView在 SwiftUI 中嵌入一​​个空是微不足道的，但是如果你想对地图做任何有用的事情，那么你需要引入一个协调器——一个可以作为你的地图视图的委托的类，将数据传入和传出 SwiftUI。创建一个继承自 的嵌套类NSObject，使其符合我们的视图或视图控制器使用的任何委托协议，并为其提供对父结构的引用，以便它可以将数据传递回 SwiftUI。对于地图视图，我们关心的协议是MKMapViewDelegate，因此我们可以立即开始编写协调器类。将此添加为内部的嵌套类MapView：
 */
class MKMapViewCoordinator: NSObject, MKMapViewDelegate {
    var parent: MKMapViewRepresentable
    var hasReceivedUserLocationOnce = false
    
    init(_ parent: MKMapViewRepresentable) {
        self.parent = parent
    }
    //自定义标记的外观
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.red
            lineView.lineWidth = 8
            lineView.fillColor = UIColor.red
            return lineView
        }
        
        fatalError("UnexpectedOverlayType")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !hasReceivedUserLocationOnce  {
            hasReceivedUserLocationOnce = true
            mapView.userTrackingMode = .follow
        }
    }
    /**
     每当地图视图更改其可见区域时，即移动、缩放或旋转时，都会调用该方法。
     */
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        parent.userTrackingMode = mapView.userTrackingMode
    }
}

struct MKMapViewRepresentable: UIViewRepresentable {
    
    @EnvironmentObject var path: CoordinatePath
    //MapView将值放入一个@Binding属性中，这意味着它实际上存储在其他地方
    @Binding var userTrackingMode: MKUserTrackingMode
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
        /**
         // 是否显示指南针（iOS9.0）
         customMapView.showsCompass = YES;
         // 是否显示比例尺（iOS9.0）
         customMapView.showsScale = YES;
         // 是否显示交通（iOS9.0）
         customMapView.showsTraffic = YES;
         // 是否显示建筑物
         customMapView.showsBuildings = YES;
         */
        let state = UIApplication.shared.applicationState
        if state == .background {
            print("Mapkit 后台渲染")
            view.showsCompass = false
            view.showsBuildings = false
        }
        else if state == .active {
            print("Mapkit 前端渲染")
            view.showsCompass = true
            view.showsBuildings = true
        }
        view.userTrackingMode = userTrackingMode
        if(path.coordinates.count > 3 ){
            let routeLine = MKPolyline(coordinates: [path.coordinates[path.coordinates.count-2],path.coordinates[path.coordinates.count-1]], count: 2)
            view.addOverlay(routeLine,level: .aboveRoads)
            
            
        }
    }
    /*
     创建一个继承自 的嵌套类NSObject，使其符合我们的视图或视图控制器使用的任何委托协议，并为其提供对父结构的引用，以便它可以将数据传递回 SwiftUI。
     
     对于地图视图，我们关心的协议是MKMapViewDelegate，因此我们可以立即开始编写协调器类。将此添加为内部的嵌套类MapView：
     */
    func makeCoordinator() -> MKMapViewCoordinator {
        MKMapViewCoordinator(self)
    }
}

struct MapView: View {
    
    @State var userTrackingMode: MKUserTrackingMode = .none
    
    var body: some View {
        ZStack {
            MKMapViewRepresentable(userTrackingMode: $userTrackingMode)
                .edgesIgnoringSafeArea(.all)
            
            if userTrackingMode != MKUserTrackingMode.follow {
                VStack {
                    Spacer()
                    HStack {
                        Button("回到当前用户位置", action: {
                            self.userTrackingMode = .follow
                        })
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
    
}


//@Binding将立即破坏MapView_Previews结构，因为它需要提供绑定。
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MKMapViewRepresentable(userTrackingMode: Binding.constant(.follow))
    }
}
