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
#   hubot sii boleta <rut> <contraseña> <monto> - Genera boleta con los datos
#     de la última generada
#
# Author:
#   lgaticaq

sii = require("sii")
Rut = require("rutjs")

getValue = (amount) ->
  return Math.round(1.1111111111111112 * amount)

module.exports = (robot) ->
  ptRut = "((\\d{7,8}|\\d{1,2}\\.\\d{3}\\.\\d{3})-[0-9Kk])"
  ptBill = "sii boleta #{ptRut} ([\\w\\W]+) ([\\d]+)"
  reBill = new RegExp(ptBill, "i")
  robot.respond reBill, (res) ->
    rut = new Rut(res.match[1])
    pass = res.match[3].trim()
    return res.reply("rut invalido") if !rut.isValid
    amount = parseInt(res.match[4], 10)
    user = {rut: rut.getNiceRut(false), password: pass}
    work = {value: getValue(amount)}
    sii.byLastInvoice(user, work)
      .then () ->
        res.send("Boleta enviada")
      .catch (err) ->
        robot.emit "error", err
        res.reply "ocurrio un error al intentar enviar la boleta"
