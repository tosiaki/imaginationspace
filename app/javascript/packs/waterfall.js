const rand = (min, max) => Math.random() * (max - min + 1) + min;

class Particle {
  constructor(canvas) {
    const newWidth = rand(1, 20);
    const newHeight = rand(1, 45);
    Object.assign(this, {
      x: rand(10 + (newWidth / 2), canvas.cw - 10 - (newWidth / 2)),
      y: -newHeight,
      vx: 0,
      vy: 0,
      width: newWidth,
      height: newHeight,
      hue: rand(200, 220),
      saturation: rand(30, 60),
      lightness: rand(30, 60),
      canvas,
      ctx: canvas.ctx
    });
  }

  update(i) {
    this.vy += this.canvas.gravity;
    this.x += this.vx;
    this.y += this.vy;
  }

  render() {
    this.ctx.strokeStyle = `hsla(${this.hue}, ${this.saturation}%, ${this.lightness}%, .05)`;
    this.ctx.beginPath();
    this.ctx.moveTo(this.x, this.y);
    this.ctx.lineTo(this.x, this.y + this.height);
    this.ctx.lineWidth = this.width / 2;
    this.ctx.lineCap = 'round';
    this.ctx.stroke();
  };

  renderBubble() {
    this.ctx.fillStyle = `hsla(${this.hue}, ${this.saturation}%, ${this.lightness}%, .3)`;
    this.ctx.beginPath();
    this.ctx.arc(this.x + this.width / 2, this.canvas.ch - 20 - rand(0, 10), rand(1, 8), 0, Math.PI * 2, false);
    this.ctx.fill();
  };
};

const waterfallCanvas = (c, cw, ch) => ({
  c,
  ctx: c.getContext('2d'),
  cw,
  ch,
  particles: [],
  particleRate: 6,
  gravity: 0.15,
  reset() {
    this.ctx.clearRect(0, 0, this.cw, this.ch);
    this.particles = [];
  },
  createParticles() {
    [...Array(this.particleRate)].map(() =>
      this.particles.push(new Particle(this)));
  },
  removeParticles() {
    for (let [index, particle] of this.particles.entries()) {
      if (particle.y > this.ch - 20 - particle.height) {
        particle.renderBubble();
        this.particles.splice(index, 1);
      }
    }
  },
  updateParticles() {
    for (let [index, particle] of this.particles.entries()) {
      particle.update(index);
    }
  },
  renderParticles() {
    for (let particle of this.particles) {
      particle.render();
    }
  },
  clearCanvas() {
    this.ctx.globalCompositeOperation = 'destination-out';
    this.ctx.fillStyle = 'rgba(255,255,255,.06)';
    this.ctx.fillRect(0, 0, this.cw, this.ch);
    this.ctx.globalCompositeOperation = 'lighter';
  },
  loop() {
    const loopIt = () => {
      requestAnimationFrame(loopIt, this.c);
      this.clearCanvas();
      this.createParticles();
      this.updateParticles();
      this.renderParticles();
      this.removeParticles();
    };
    loopIt();
  }
});

const isCanvasSupported = () => {
  const elem = document.createElement('canvas');
  return !!(elem.getContext && elem.getContext('2d'));
};

const setupRAF = () => {
  let lastTime = 0;
  const vendors = ['ms', 'moz', 'webkit', 'o'];
  for (let x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] || window[vendors[x] + 'CancelRequestAnimationFrame'];
  }
  if (!window.requestAnimationFrame) {
    window.requestAnimationFrame = function(callback, element) {
      const currTime = new Date().getTime();
      const timeToCall = Math.max(0, 16 - (currTime - lastTime));
      const id = window.setTimeout(function() {
        callback(currTime + timeToCall);
      }, timeToCall);
      lastTime = currTime + timeToCall;
      return id;
    };
  }
  if (!window.cancelAnimationFrame) {
    window.cancelAnimationFrame = function(id) {
      clearTimeout(id);
    };
  }
};

document.addEventListener('turbolinks:load', () => {
  if (isCanvasSupported()) {
    const c = document.getElementById('waterfall');
    const cw = c.width = Math.max(c.scrollWidth, c.offsetWidth, c.clientWidth, c.scrollWidth, c.offsetWidth);
    const ch = c.height = Math.max(c.scrollHeight, c.offsetHeight, c.clientHeight, c.scrollHeight, c.offsetHeight);
    const waterfall = waterfallCanvas(c, cw, ch);
    setupRAF();
    waterfall.loop();
  }

  /* Second plugin */
  let w, h, renderer, stage, waveGraphics, partGraphics, waveTexture, partTexture, waveCount, partCount, waves, parts;

  const init = () => {
    renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight / 2, {
      transparent: true
    });
    stage = new PIXI.Container();
    waveCount = 2000;
    partCount = 1000;
    waves = [];
    parts = [];
    document.getElementById('waterfall-container').appendChild(renderer.view);
    reset();
    [...Array(300)].map(() => step());
    loop();
  }

  const reset = () => {
    w = window.innerWidth;
    h = window.innerHeight;
    renderer.resize(w, h);
    waveGraphics = null;
    waveTexture = null;
    partGraphics = null;
    partTexture = null;
    waveGraphics = new PIXI.Graphics();
    waveGraphics.cacheAsBitmap = true;
    waveGraphics.beginFill('0x' + tinycolor('hsl(200, 74%, 40%)').toHex(), 0.10);
    waveGraphics.drawCircle(0, 0, 20);
    waveGraphics.endFill();
    waveTexture = waveGraphics.generateTexture();
    partGraphics = new PIXI.Graphics();
    partGraphics.cacheAsBitmap = true;
    partGraphics.beginFill('0x' + tinycolor('hsl(200, 70%, 40%)').toHex(), 0.13);
    partGraphics.drawCircle(0, 0, 15);
    partGraphics.endFill();
    partTexture = partGraphics.generateTexture();
  }

  const step = () => {
    if (waves.length < waveCount) {
      [...Array(10)].map(() => {
        const wave = new PIXI.Sprite(waveTexture),
          scale = 0.2 + Math.random() * 0.8;
        wave.position.x = w / 2;
        wave.position.y = h / 2;
        wave.anchor.x = 0.5;
        wave.anchor.y = 0.5;
        wave.scale.x = scale * 25;
        wave.scale.y = scale * 0.5;
        wave.blendMode = PIXI.BLEND_MODES.SCREEN;
        waves.push({
          sprite: wave,
          x: wave.position.x,
          y: wave.position.y,
          vx: 0,
          vy: 0,
          angle: Math.PI / 2 + Math.random() * Math.PI + Math.PI * 1.5,
          speed: 0.01 + Math.random() / 10
        });
        stage.addChild(wave);
      });
    }
    for (let wave of waves) {
      wave.sprite.position.x = wave.x;
      wave.sprite.position.y = wave.y;
      wave.vx = Math.cos(wave.angle) * wave.speed;
      wave.vy = Math.sin(wave.angle) * wave.speed;
      wave.x += wave.vx;
      wave.y += wave.vy;
      wave.speed *= 1.01;
      if (wave.x > w + 200 || wave.x < -200 || wave.y > h + 200) {
        wave.x = w / 2;
        wave.y = h / 2;
        wave.speed = 0.01 + Math.random() / 10;
      }
    }
    if (parts.length < partCount) {
      const part = new PIXI.Sprite(partTexture),
        scale = 0.2 + Math.random() * 0.8,
        type = Math.random() > 0.5 ? 1 : 0;
      part.position.x = w / 2 + Math.random() * 380 - 190;
      part.position.y = h / 2 + 0;
      part.anchor.x = 0.5;
      part.anchor.y = 0.5;
      part.scale.x = type ? scale : scale * 0.5;
      part.scale.y = type ? scale : scale * 15;
      part.blendMode = PIXI.BLEND_MODES.SCREEN;
      parts.push({
        sprite: part,
        ox: part.position.x,
        oy: part.position.y,
        x: part.position.x,
        y: part.position.y,
        vx: 0,
        vy: 0,
        angle: (-Math.PI * 0.5) + (w / 2 - part.position.x) / 750,
        speed: 0.0001 + Math.random() / 50
      });
      stage.addChild(part);
    }
    for (let part of parts) {
      part.sprite.position.x = part.x;
      part.sprite.position.y = part.y;
      part.vx = Math.cos(part.angle) * part.speed;
      part.vy = Math.sin(part.angle) * part.speed;
      part.x += part.vx;
      part.y += part.vy;
      part.speed *= 1.01;
      part.speed += Math.random() / 10;
      if (part.x > w + 50 || part.x < -50 || part.y < -50) {
        part.x = part.ox;
        part.y = part.oy;
        part.speed = 0.01 + Math.random() / 50;
      }
    }
    renderer.render(stage);
  }

  function loop() {
    step();
    requestAnimationFrame(loop);
  }
  window.addEventListener('resize', reset);
  init();
});
