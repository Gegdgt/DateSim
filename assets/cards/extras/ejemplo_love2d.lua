-- Ejemplo ilustrativo LÖVE 2D (sustituye la ruta base por la de tu proyecto)
local raiz = 'Mushoku_Tensei_Cartas_Del_Destino/'
local img = {}
function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  img.base = love.graphics.newImage(raiz .. 'bases/fondo_pergamino.png')
  img.marco = love.graphics.newImage(raiz .. 'marcos/marco_empatia.png')
  img.icono = love.graphics.newImage(raiz .. 'iconos/escuchar.png')
  img.reverso = love.graphics.newImage(raiz .. 'reverso/reverso_espejo.png')
  img.fuente = love.graphics.newFont(12)
  love.graphics.setFont(img.fuente)
end
function love.draw()
  local x, y, escala = 45, 30, 3
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img.base, x, y, 0, escala, escala)
  love.graphics.draw(img.marco, x, y, 0, escala, escala)
  love.graphics.draw(img.icono, x + 28*escala, y + 31*escala, 0, escala, escala)
  love.graphics.setColor(0.14, 0.13, 0.22, 1)
  love.graphics.print('Escuchar', x + 12*escala, y + 12*escala, 0, 1, 1)
  love.graphics.print('Coste: 0', x + 12*escala, y + 94*escala, 0, 1, 1)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img.reverso, x + 90*escala, y, 0, escala, escala)
end
