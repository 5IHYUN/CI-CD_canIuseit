pipeline {
    agent any

    environment {
        // Secret File을 가져오는 부분
        MY_ENV_FILE = credentials('MY_ENV_FILE')  // .env 파일의 Jenkins credentials ID
        NETWORK_NAME = 'mynetwork'  // 네트워크 이름 
        DB_CONTAINER_NAME = 'mysql-container'  // DB 컨테이너 이름 
        WEB_CONTAINER_NAME = 'app-container'  // 웹 컨테이너 이름 
        WEB_IMAGE_NAME = 'shkim5971/my-node-app:latest'  // 웹 이미지 이름 수
        JENKINS_SERVER_ADDR = '34.64.72.211'

        // Docker Hub 크리덴셜 추가
        // DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials'  // Docker Hub 크리덴셜 ID
        // DOCKER_HUB_USERNAME = credentials('docker-hub-credentials')  // Docker Hub 사용자 이름
        // DOCKER_HUB_PASSWORD = credentials('docker-hub-credentials')  // Docker Hub 비밀번호
    }

    stages {
        stage('Extract Env Variables') {
            steps {
                script {
                    
                    // .env 파일을 작업 디렉토리에 복사
					sh "cat ${MY_ENV_FILE} > backend/.env"

                    // .env 파일 권한 확인 후, 읽기/쓰기 권한 추가
                    sh 'chmod 644 backend/.env'

                    // 작업 디렉토리에 쓰기 권한 부여
                    sh 'chmod 777 .'


                }
            }
        }
        stage('Create docker network') {
            steps {
                sh 'docker network create $NETWORK_NAME || true'
            }
        }

        stage('Run DB Container') {
            steps {
                script {
                    sh '''
                    docker run -d --name $DB_CONTAINER_NAME \
                    --network $NETWORK_NAME \
                    -e MYSQL_ROOT_PASSWORD=tlgus051016 \
                    -e MYSQL_DATABASE=canIuseit_db \
                    -p 3306:3306 mysql:8
                    '''
                }
            }
        }

        stage('Build Web Container') {
            steps {
                script {
                    // Docker 빌드 전에 backend/.env를 빌드 컨텍스트 루트로 복사
                    sh 'cp backend/.env .'
                    sh 'docker build -t $WEB_IMAGE_NAME .'
                }
            }
        }

        stage('Run Web Container') {
            steps {
                script {
                    sh "docker run -d --name $WEB_CONTAINER_NAME --network $NETWORK_NAME -p 3000:3000 $WEB_IMAGE_NAME"
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    sh '''
                    echo "Checking container is available..."
                    docker ps
                    echo "Waiting for DB to initialize..."
                    sleep 20	
                    echo "Sending request to the server..."
								    docker logs $WEB_CONTAINER_NAME
								    RESPONSE=$(docker exec $WEB_CONTAINER_NAME curl --max-time 10 -s -w "%{http_code}" -o /dev/null http://localhost:3000)
								    if [ "$RESPONSE" -eq 200 ]; then
								    	echo "Server is running properly. HTTP Status: $RESPONSE"
								    else
						    			echo "Test failed! HTTP Status: $RESPONSE"
								    fi
                    '''
                }
            }
        }
        // Docker Hub에 이미지를 푸시하는 단계 추가
        // stage('Push Image to Docker Hub') {
        //     steps {
        //         script {
        //             // Docker Hub 로그인
        //             sh "docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD"

        //             // Docker Hub에 이미지 푸시
        //             sh "docker push $WEB_IMAGE_NAME"
        //         }
        //     }
        // }
    }

    post {
        always {
            echo 'Cleaning up Docker resources...'
            sh '''
            docker stop $WEB_CONTAINER_NAME $DB_CONTAINER_NAME || true
            docker rm $WEB_CONTAINER_NAME $DB_CONTAINER_NAME || true
            docker rmi $WEB_IMAGE_NAME || true
            docker network rm $NETWORK_NAME || true
            '''
        }
    }
}
