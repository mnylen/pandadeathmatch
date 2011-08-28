var evt = require('events')
  , _ = require('underscore')
  , uid = require('./uid')
  , params = require('./params')
  , geom = require('./geometry')
  , movement = require('./movement')
  , game = new evt.EventEmitter()
  , pandas = {}
  , newPandas = {}
  , removedPandas = []
  , pandaMovementCommands = []
  , projectiles = {}
  , newProjectiles = {}
  , collidedProjectiles = []
  , explosions = {}
  , newExplosions = {};

// External API

game.playerJoined = function(id, nick) {
  var playerPos = movement.findNewPosForPanda(pandas);
  newPandas[id] = {
    nick: nick,
    x: playerPos.x,
    y: playerPos.y,
    dir: params.Direction.NONE,
    moving: 0,
    health: params.pandaStartHealth,
    score: 0
  };
};
game.playerLeft = function(id) {
  removedPandas.push(id);
};
game.playerStartedMoving = function(id, dir) {
  pandaMovementCommands.push({id: id, moving: 1, dir: dir});
};
game.playerStoppedMoving = function(id) {
  pandaMovementCommands.push({id: id, moving: 0});
};
game.playerFired = function(id) {
  if (playerHasRecentlyFired(id)) return;
  
  var panda = pandas[id]
    , projectileDimensions = getProjectileDimensions(panda.dir)
    , x = panda.x
    , y = panda.y;
    
  switch (panda.dir) {
    case params.Direction.UP:
      x += ((params.pandaWidth / 2) - (projectileDimensions.width / 2));
      y -= projectileDimensions.height;
      break;
    case params.Direction.DOWN:
      x += ((params.pandaWidth / 2) - (projectileDimensions.width / 2));
      y += params.pandaHeight;
      break;
    case params.Direction.LEFT:
      x -= projectileDimensions.width;
      y += ((params.pandaHeight / 2) - (projectileDimensions.height / 2));
      break;
    case params.Direction.RIGHT:
      x += params.pandaWidth;
      y += ((params.pandaHeight / 2) - (projectileDimensions.height / 2));
      break;
  }
  newProjectiles[uid()] = {x: Math.floor(x), y: Math.floor(y), dir: panda.dir, owner: id, firedAt: new Date().getTime()};
};

game.getState = function() {
  return {
    newElements: {
      PANDA: pandas,
      PROJECTILE: projectiles,
      EXPLOSION: explosions
    }
  };
};

game.getNicks = function() {
  return _(pandas).pluck('nick');
}

// Internal stuff

function playerHasRecentlyFired(playerId) {
  var recent = new Date().getTime() - 1800;
  return _(projectiles).detect(function(proj) {
    return proj.owner === playerId && proj.firedAt > recent;
  });
}

function removeProjectilesOutsideGameArea() {
  var removedIds = [];
  projectiles = _(projectiles).reduce(function(toKeep, proj, id) {
    if (proj.x >= 0 && proj.x <= params.gameWidth &&
        proj.y >= 0 && proj.y <= params.gameHeight) {
      toKeep[id] = proj;
    } else {
      removedIds.push(id);
    }
    return toKeep;
  }, {});
  return removedIds;
};

function getProjectileDimensions(dir) {
  if (dir === params.Direction.LEFT || dir === params.Direction.RIGHT) {
    return {width: params.projectileWidth, height: params.projectileHeight};
  } else {
    return {width: params.projectileHeight, height: params.projectileWidth};
  }
};

function poorPandaWasShot(panda, shooter) {
  panda.health -= params.projectileDamage;
  if (panda.health <= 0) {
      var regenPos = movement.findNewPosForPanda(pandas);
      if (shooter) {
          shooter.score += params.projectileKillScore;
      }
      panda.x = regenPos.x;
      panda.y = regenPos.y;
      panda.moving = 0;
      panda.health = params.pandaStartHealth;
  }
}

function applyProjectileCollisions() {
  _(projectiles).each(function(proj, id) {
    var projDim = getProjectileDimensions(proj.dir);
    _(pandas).each(function (panda) {
      if (geom.rectsIntersect(proj.x,  proj.y,  projDim.width,     projDim.height,
                              panda.x, panda.y, params.pandaWidth, params.pandaHeight)) {
        collidedProjectiles.push(id);                            
        newExplosions[uid()] = {x: panda.x, y: panda.y, age: 0};
        poorPandaWasShot(panda, pandas[proj.owner]);
      }
    });
  });
};

function removeDistinguishedExplosions() {
  var removedIds = [];
  explosions = _(explosions).reduce(function(memo, expl, id) {
    if (expl.age <= params.explosionDuration) {
      expl.age += 1000 / params.frameRate;
      memo[id] = expl
    } else {
      removedIds.push(id);
    }
    return memo;
  }, {});
  return removedIds;
}

// The game loop

(function gameLoop() {
  applyProjectileCollisions();
  
  var stateDelta = {};
  
  var removedElements = applyRemovedElements();
  if (!_(removedElements).isEmpty()) stateDelta.removedElements = removedElements;
    
  var newElements = applyNewElements();
  if (!_(newElements).isEmpty()) stateDelta.newElements = newElements;

  var deltas = applyMovements();
  if (!_(deltas).isEmpty()) stateDelta.deltas = deltas;
  
  if (!_(stateDelta).isEmpty()) {
    game.emit('stateDelta', stateDelta);
  }

  setTimeout(gameLoop, 1000 / params.frameRate);
})();

function applyRemovedElements() {
  var removedElements = [];
  
  removedElements = removedElements.concat(collidedProjectiles);
  removedElements = removedElements.concat(removeProjectilesOutsideGameArea());
  removedElements = removedElements.concat(removeDistinguishedExplosions());
  removedElements = removedElements.concat(removedPandas);
  
  _(removedPandas).each(function(id) {
    delete pandas[id];
  });
  removedPandas = [];
  collidedProjectiles = [];
  
  return removedElements;
}

function applyNewElements() {
  var newElements = {};
  
  if (!_(newPandas).isEmpty())      newElements.PANDA = newPandas;
  if (!_(newProjectiles).isEmpty()) newElements.PROJECTILE = newProjectiles;
  if (!_(newExplosions).isEmpty())  newElements.EXPLOSION = newExplosions;
  
  _(pandas).extend(newPandas);
  newPandas = {};
  _(projectiles).extend(newProjectiles);
  newProjectiles = {};
  _(explosions).extend(newExplosions);
  newExplosions = {};

  return newElements;
}

function applyMovements() {
  var deltas = {};
  
  _(pandaMovementCommands).each(function(cmd) {
    if (!deltas[cmd.id]) deltas[cmd.id] = {};
    deltas[cmd.id].moving = cmd.moving;
    pandas[cmd.id].moving = cmd.moving;
    if (cmd.dir) {
      deltas[cmd.id].dir = cmd.dir;
      pandas[cmd.id].dir = cmd.dir;
    }
  });
  pandaMovementCommands = [];
  
  var pandaPositionDeltas = movement.updatePandaPositions(pandas);
  _(pandaPositionDeltas).each(function(delta, id) {
    if (!deltas[id]) deltas[id] = {};
    _(deltas[id]).extend(delta);
  });
  
  var projectilePositionUpdates = movement.updateProjectilePositions(projectiles);
  _(projectilePositionUpdates).each(function(update, id) {
    if (!deltas[id]) deltas[id] = {};
    _(deltas[id]).extend(update);
  });
  
  return deltas;
}




module.exports = game;
