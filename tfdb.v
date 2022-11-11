module main

import freeflowuniverse.crystallib.redisserver
import freeflowuniverse.crystallib.resp

fn command_ping(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_namedefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_groupdefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hashdefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_circleget(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hashget(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hashdelete(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hset(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hsecure(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hscan(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hlen(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_hdel(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}



fn main() {
	mut srv := redisserver.listen('0.0.0.0', 5555) or {
		panic("Can't Listen on port with error: $err")
	}

	mut main := &redisserver.RedisInstance{}

	mut h := []redisserver.RedisHandler{}
	h << redisserver.RedisHandler{
		command: 'PING'
		handler: command_ping
	}

	h << redisserver.RedisHandler{
		command: 'NAMEDEFINE'
		handler: command_namedefine
	}

	h << redisserver.RedisHandler{
		command: 'GROUPDEFINE'
		handler: command_groupdefine
	}

	h << redisserver.RedisHandler{
		command: 'HASHDEFINE'
		handler: command_hashdefine
	}

	h << redisserver.RedisHandler{
		command: 'CIRCLEGET'
		handler: command_circleget
	}

	h << redisserver.RedisHandler{
		command: 'HASHGET'
		handler: command_hashget
	}

	h << redisserver.RedisHandler{
		command: 'HASHDELETE'
		handler: command_hashdelete
	}

	h << redisserver.RedisHandler{
		command: 'HSET'
		handler: command_hset
	}

	h << redisserver.RedisHandler{
		command: 'HSECURE'
		handler: command_hsecure
	}

	h << redisserver.RedisHandler{
		command: 'HSCAN'
		handler: command_hscan
	}

	h << redisserver.RedisHandler{
		command: 'HLEN'
		handler: command_hlen
	}

	h << redisserver.RedisHandler{
		command: 'HDEL'
		handler: command_hdel
	}


	for {
		println('still looping...')
		mut conn := srv.socket.accept() or { continue }
		go redisserver.new_client_custom(mut conn, mut main, h)
	}

}

