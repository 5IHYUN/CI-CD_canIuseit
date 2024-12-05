# 1. Alpine 기반 Node.js 이미지
FROM node:16-alpine

# 2. curl 설치
RUN apk add --no-cache curl

# 작업 디렉토리 설정
WORKDIR /usr/src/app

# 전체 프로젝트 소스 코드 복사
COPY . .

# 백엔드 이동
WORKDIR /usr/src/app/backend

# 필요한 패키지 설치
RUN npm install

# 서버 실행 포트 공개
EXPOSE 3000

# 젠킨스에 존재하는 .env 파일을 컨테이너로 복사
COPY .env .env 

# 6. 서버 시작 명령어
CMD ["npm", "start"]

# 테스트?