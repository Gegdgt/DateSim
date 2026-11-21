-- Revisión humana sin editar la campaña del jugador ni saltar checkpoints.
local Review={}
function Review.new(seed)
 love.filesystem.setIdentity("cartas_del_destino_phase6_manual")
 love.math.setRandomSeed(seed or 17)
 local app=require("src.app").new()
 local sequence=0;local runId=os.date("%Y%m%d-%H%M%S")
 function app:qaCapture()
  sequence=sequence+1
  local checkpoint=self.session and self.session.checkpoint or "menu"
  local prefix=string.format("manual-%s-%03d-%s",runId,sequence,checkpoint)
  local root=love.filesystem.getSource().."/tests/artifacts/"
  self.toastTime=0;self:draw()
  local pixels=self.canvas:newImageData();local bytes=pixels:encode("png")
  local f=assert(io.open(root..prefix..".png","wb"));f:write(bytes:getString());f:close();pixels:release();bytes:release()
  local record={checkpoint=checkpoint,day=self.session and self.session.day,screen=self.manager.current.kind or "dialogue",seed=seed or 17,
   note="Captura solicitada con F8; no certifica una partida manual completa."}
  f=assert(io.open(root..prefix..".json","wb"));f:write(assert(require("src.systems.json").encode(record)));f:close()
  self:notify("Captura guardada: "..prefix..".png")
 end
 return app
end
return Review
