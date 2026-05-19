# 필름인 - Filmin

필름 카메라 유저를 위한 롤 관리 iOS 앱.

## 개발 환경

- Xcode 16.4+
- iOS 17.0+
- Swift 5.10
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (프로젝트 생성용)

## 시작하기

```sh
# 의존성 (한 번만)
brew install xcodegen

# Xcode 프로젝트 생성
xcodegen

# Xcode 열기
open Filmin.xcodeproj
```

`Filmin.xcodeproj`는 `.gitignore`에 들어가 있어. 클론 후 위 명령으로 생성하면 됨.

## 구조

```
Filmin/
├── FilminApp.swift              # 앱 엔트리
├── Models/
│   └── FilmRoll.swift           # 필름 롤 모델 + 샘플 데이터
├── Views/
│   ├── MyFilmsView.swift        # 메인 페이지
│   └── Components/
│       ├── FilmRollCard.swift   # 그리드 카드
│       └── FilmCanisterView.swift  # 필름통 일러스트 (SwiftUI 드로잉)
└── Assets.xcassets
```
