Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value 'docker-compose'
Set-Alias -Name ca -Value cargo

function dcd() {
    docker-compose down --remove-orphans -v --rmi local
}

function dcu() {
    docker-compose down --remove-orphans -v --rmi local
    docker-compose up
}

function ddf () {
    docker system df
}

function dsp() {
    docker system prune -a -f --volumes
}

function dotenv() {
    get-content .env | foreach {
        $name, $value = $_.split('=')
        set-content env:\$name $value
    }
}