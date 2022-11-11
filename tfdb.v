module main

import freeflowuniverse.crystallib.redisserver
import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.resp

[heap]
struct TFDBSrv {
mut:
	client redisclient.Redis
}

fn (mut t TFDBSrv) command_ping(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_namedefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 4 {
		return resp.r_error("Invalid arguments")
	}

	name := resp.get_array_value(input, 1)
	link := resp.get_array_value(input, 2)
	dns := resp.get_array_value(input, 3)

	if name.len < 12 {
		return resp.r_error("Name needs to be minimum 12 bytes")
	}

	return resp.r_ok()
}

fn (mut t TFDBSrv) command_groupdefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_ok()
}

fn (mut t TFDBSrv) command_hashdefine(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 2 {
		return resp.r_error("Invalid arguments")
	}

	// let use two namespaces to achieve this easily:
	//  - one namespace (hashnames) in userkey mode, which contains a key/value per name
	//    to keep track of which names are in use or not
	//  - another namespace (hashes) in sequential mode, which will create a unique id
	//    on creation (and contains name as value)
	//
	// this allows easy check of existance and unique id generation easily

	name := resp.get_array_value(input, 1)

	t.client.send_expect_ok(["SELECT", "hashnames"]) or { panic(err) }

	value := t.client.get(name) or {
		// does not exists, we can create it
		t.client.send_expect_str(["SET", name, name]) or { panic(err) }

		// switch to hashes id namespace
		t.client.send_expect_ok(["SELECT", "hashes"]) or { panic(err) }

		// FIXME: does not support binary response
		apply := t.client.send_expect_str(["SET", "", name]) or { panic(err) }
		return resp.r_string(apply)
	}

	return resp.r_error("Name already exists")
}

fn (mut t TFDBSrv) command_groupget(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hashget(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hashdelete(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn (mut t TFDBSrv) command_hset(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 4 {
		return resp.r_error("Invalid arguments")
	}

	key := resp.get_array_value(input, 1)
	field := resp.get_array_value(input, 2)
	data := resp.get_array_value(input, 3)

	t.client.send_expect_ok(["SELECT", "hdata"]) or { panic(err) }
	t.client.send_expect_str(["SET", "${key}.${field}", data]) or { panic(err) }

	return resp.r_ok()
}

fn (mut t TFDBSrv) command_hsecure(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 3 {
		return resp.r_error("Invalid arguments")
	}

	return resp.r_ok()
}

fn (mut t TFDBSrv) command_hget(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 3 {
		return resp.r_error("Invalid arguments")
	}

	key := resp.get_array_value(input, 1)
	field := resp.get_array_value(input, 2)

	t.client.send_expect_ok(["SELECT", "hdata"]) or { panic(err) }
	data := t.client.send_expect_str(["GET", "${key}.${field}"]) or { return resp.r_nil() }

	return resp.r_string(data)
}

fn (mut t TFDBSrv) command_hscan(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 3 {
		return resp.r_error("Invalid arguments")
	}

	return resp.r_ok()
}

fn (mut t TFDBSrv) command_hlen(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 2 {
		return resp.r_error("Invalid arguments")
	}

	// FIXME: no idea how to implement that right now

	return resp.r_ok()
}

fn (mut t TFDBSrv) command_hdel(input resp.RValue, mut _ redisserver.RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 3 {
		return resp.r_error("Invalid arguments")
	}

	key := resp.get_array_value(input, 1)
	field := resp.get_array_value(input, 2)

	t.client.send_expect_ok(["SELECT", "hdata"]) or { panic(err) }
	data := t.client.send_expect_str(["DEL", "${key}.${field}"]) or { return resp.r_nil() }

	return resp.r_ok()
}



fn main() {
	mut srv := redisserver.listen('0.0.0.0', 5555) or {
		panic("Can't Listen on port with error: $err")
	}

	mut main := &redisserver.RedisInstance{}

	mut tfdb := TFDBSrv{}
	tfdb.client = redisclient.get('127.0.0.1:9900')!
	tfdb.client.ping()!

	mut h := []redisserver.RedisHandler{}
	h << redisserver.RedisHandler{
		command: 'PING'
		handler: tfdb.command_ping
	}

	h << redisserver.RedisHandler{
		command: 'NAMEDEFINE'
		handler: tfdb.command_namedefine
	}

	h << redisserver.RedisHandler{
		command: 'GROUPDEFINE'
		handler: tfdb.command_groupdefine
	}

	h << redisserver.RedisHandler{
		command: 'HASHDEFINE'
		handler: tfdb.command_hashdefine
	}

	h << redisserver.RedisHandler{
		command: 'GROUPGET'
		handler: tfdb.command_groupget
	}

	h << redisserver.RedisHandler{
		command: 'HASHGET'
		handler: tfdb.command_hashget
	}

	h << redisserver.RedisHandler{
		command: 'HASHDELETE'
		handler: tfdb.command_hashdelete
	}

	h << redisserver.RedisHandler{
		command: 'HSET'
		handler: tfdb.command_hset
	}

	h << redisserver.RedisHandler{
		command: 'HSECURE'
		handler: tfdb.command_hsecure
	}

	h << redisserver.RedisHandler{
		command: 'HGET'
		handler: tfdb.command_hget
	}

	h << redisserver.RedisHandler{
		command: 'HSCAN'
		handler: tfdb.command_hscan
	}

	h << redisserver.RedisHandler{
		command: 'HLEN'
		handler: tfdb.command_hlen
	}

	h << redisserver.RedisHandler{
		command: 'HDEL'
		handler: tfdb.command_hdel
	}


	for {
		println('still looping...')
		mut conn := srv.socket.accept() or { continue }
		go redisserver.new_client_custom(mut conn, mut main, h)
	}

}

