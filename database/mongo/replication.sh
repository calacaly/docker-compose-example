docker help | grep compose && DOCKER_COMPOSE="docker compose" || DOCKER_COMPOSE="docker-compose"
MONGO_COMPOSE_FILE="mongo-replication-single.yml"
MONGO_PRIMARIY_HOST="mongo0"
MONGO_USER="root"
MONGO_PASS="123456"
MONGO_PORT="27017"

MONGO_DSN="mongodb://${MONGO_USER}:${MONGO_PASS}@${MONGO_PRIMARIY_HOST}:${MONGO_PORT}"

RS_CONF='rs.initiate({_id:"rs0",members:[{_id:0,host:"mongo0:27017",priority:1},{_id:1,host:"mongo1:27017",priority:0.5},{_id:2,host:"mongo2:27017",priority:0.5}]})'

CREATE_USER_CONF='db.createUser({user:'"'${MONGO_USER}'"',pwd:'"'${MONGO_PASS}'"',roles:[{role:"root",db:"admin"}]})'


function Config(){
	rm -rf docker-compose.yml;cp ${MONGO_COMPOSE_FILE} docker-compose.yml
}

function GenKey(){
	openssl rand -base64 756 > keyfile
	chmod 400 keyfile
}

function Start(){
	# start replication
	${DOCKER_COMPOSE} --file ${MONGO_COMPOSE_FILE} up -d
}



function Init(){
	# init replication
	${DOCKER_COMPOSE} --file ${MONGO_COMPOSE_FILE} exec ${MONGO_PRIMARIY_HOST} mongosh --eval "${RS_CONF}"
	sleep 10s
	# init password
	${DOCKER_COMPOSE} --file ${MONGO_COMPOSE_FILE} exec ${MONGO_PRIMARIY_HOST} mongosh admin --eval "${CREATE_USER_CONF}"
}


function Status(){
	# status replication
	${DOCKER_COMPOSE} --file ${MONGO_COMPOSE_FILE} exec ${MONGO_PRIMARIY_HOST} mongosh ${MONGO_DSN} --eval 'rs.status("rs0")'
}
Config
GenKey
Start
Init
Status
