# GitHub Pages 배포 가이드

이 프로젝트는 GitHub Actions를 통해 GitHub Pages에 자동으로 배포되도록 설정되어 있습니다.

## 배포 설정 방법

1. **코드 푸시 (Push)**
   - `.github/workflows/deploy.yml` 파일이 포함된 코드를 GitHub 저장소의 `main` 브랜치에 푸시합니다.
   - 푸시가 되면 자동으로 Actions 탭에서 `Deploy to GitHub Pages` 워크플로우가 실행됩니다.
   - 첫 실행 시에는 `gh-pages` 브랜치에 배포 파일들이 생성됩니다.

2. **GitHub 저장소 설정 (Settings)**
   - GitHub 저장소 페이지의 상단 메뉴에서 **Settings**를 클릭합니다.
   - 왼쪽 사이드바에서 **Pages** 메뉴를 클릭합니다.
   - **Build and deployment** 섹션에서 다음 설정을 확인합니다:
     - **Source**: `Deploy from a branch` 선택
     - **Branch**: `gh-pages` 선택, 폴더는 `/ (root)` 선택
   - **Save** 버튼을 클릭하여 저장합니다.

3. **배포 확인**
   - 설정이 완료되면 GitHub Pages가 다시 로드되며 배포가 진행됩니다.
   - 잠시 후 화면 상단에 배포된 사이트의 URL이 표시됩니다. (예: `https://kimhyunseo.github.io/flutter_web2/`)

## 주의사항

- **Base Href**: 현재 설정은 리포지토리 이름이 `flutter_web2`라고 가정하고 `--base-href "/flutter_web2/"` 옵션을 사용합니다. 만약 리포지토리 이름이 다르다면 `.github/workflows/deploy.yml` 파일에서 해당 부분을 수정해야 합니다.
- **Custom Domain**: 커스텀 도메인을 사용하는 경우 추가 설정이 필요할 수 있습니다.
