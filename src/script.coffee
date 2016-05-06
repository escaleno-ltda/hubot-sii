# Description
#   Script de hubot para crear boleta de honorarios
#
# Dependencies:
#   "rutjs": "^0.1.1"
#   "sii": "0.0.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot sii contribuidor <nombre> <rut> <direccion>
#   hubot sii contribuidores
#   hubot sii boleta <rut> <contraseña> <rut contribuidor> <monto>
#     <descripcion>
#
# Author:
#   lgaticaq

sii = require("sii")
Rut = require("rutjs")

getValue = (amount) ->
  return Math.round(1.1111111111111112 * amount)

module.exports = (robot) ->
  ptRut = "((\\d{7,8}|\\d{1,2}\\.\\d{3}\\.\\d{3})-[0-9Kk])"
  ptContributor = "sii contribuidor ([\\w\\W]+) #{ptRut} ([\\w\\W]+)"
  reContributor = new RegExp(ptContributor, "i")
  robot.respond reContributor, (res) ->
    name = res.match[1].trim().toUpperCase()
    rut = new Rut(res.match[2])
    return res.reply("rut invalido") unless rut.isValid
    address = res.match[3].trim().toUpperCase()
    exist = robot.brain.get("sii:contributors:#{rut.getNiceRut()}")
    unless exist
      values = ["name", name, "rut", rut.getNiceRut(), "address", address]
      robot.brain.hmset("sii:contributors:#{rut.getNiceRut()}", values)
    res.send("Contribuidor guardado")

  robot.respond /sii contribuidores/i, (res) ->
    keys = robot.brain.keys("sii:contributors:*")
    names = keys.map((x) -> robot.brain.hmget(key, "name", "rut"))
    if names.length > 0
      res.send(names.map((x) -> "#{x.name} (#{x.rut})").join(", "))
    else
      res.send("No hay contribuidores guardados")

  ptBill = "sii boleta #{ptRut} ([\\w\\W]+) #{ptRut} ([\\d]+) ([\\w\\W]+)"
  reBill = new RegExp(ptBill, "i")
  robot.respond reBill, (res) ->
    rut = new Rut(res.match[1])
    pass = res.match[3].trim().toUpperCase()
    rut2 = new Rut(res.match[4])
    return res.reply("rut invalido") if !rut.isValid or !rut2.isValid
    amount = parseInt(res.match[6], 10)
    description = res.match[7].trim().toUpperCase()
    key = "sii:contributors:#{rut2.getNiceRut()}"
    contributor = robot.brain.hmget(key, "name", "address")
    unless contributor
      return res.reply("el contribuidor no existe")
    user = {rut: rut.getNiceRut(), password: pass}
    work = {description: description, value: getValue(amount)}
    destinatary =
      rut: rut2.rut
      dv: rut2.checkDigit
      name: contributor.name
      address: contributor.address
    sii.byDestinatary(user, work, destinatary, zone, commune)
      .then () ->
        res.send("Boleta enviada")
      .catch (err) ->
        robot.emit "error", err
        res.reply "ocurrio un error al intentar enviar la boleta"
