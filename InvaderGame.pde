// Simple Shooting Game in Processing
// Player controls a ship at the bottom of the screen.
// Use LEFT/RIGHT arrows to move and SPACE to shoot.

// Game objects
Player player;
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

// Game state
boolean gameOver = false;
boolean victory = false;

void setup() {
    size(600, 800);
    player = new Player(width/2, height - 40);
    initEnemies();
}

void draw() {
    background(0);
    if (!gameOver) {
        player.update();
        player.display();
        for (int i = bullets.size() - 1; i >= 0; i--) {
            Bullet b = bullets.get(i);
            b.update();
            b.display();
            if (b.offscreen()) {
                bullets.remove(i);
            } else {
                // check collision with enemies
                for (int j = enemies.size() - 1; j >= 0; j--) {
                    Enemy e = enemies.get(j);
                    if (e.hitBy(b)) {
                        enemies.remove(j);
                        bullets.remove(i);
                        break;
                    }
                }
            }
        }
        for (Enemy e : enemies) {
            e.update();
            e.display();
            if (e.y + e.h/2 >= height - 60) {
                gameOver = true;
            }
        }
        if (enemies.isEmpty()) {
            victory = true;
            gameOver = true;
        }
    } else {
        textAlign(CENTER, CENTER);
        fill(255);
        textSize(36);
        if (victory) {
            text("YOU WIN!", width/2, height/2);
        } else {
            text("GAME OVER", width/2, height/2);
        }
    }
}

void keyPressed() {
    if (keyCode == LEFT) {
        player.move(-1);
    } else if (keyCode == RIGHT) {
        player.move(1);
    } else if (key == ' ' && bullets.size() < 3) {
        bullets.add(new Bullet(player.x, player.y - player.h/2));
    } else if (gameOver && key == 'r') {
        restartGame();
    }
}

void keyReleased() {
    if (keyCode == LEFT || keyCode == RIGHT) {
        player.move(0);
    }
}

void initEnemies() {
    enemies.clear();
    int cols = 6;
    int rows = 3;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            float ex = 80 + j * 80;
            float ey = 60 + i * 60;
            enemies.add(new Enemy(ex, ey));
        }
    }
}

void restartGame() {
    player = new Player(width/2, height - 40);
    bullets.clear();
    initEnemies();
    gameOver = false;
    victory = false;
}

class Player {
    float x;
    float y;
    float w = 40;
    float h = 20;
    float speed = 5;
    int direction = 0;
    Player(float x, float y) {
        this.x = x;
        this.y = y;
    }
    void update() {
        x += direction * speed;
        x = constrain(x, w/2, width - w/2);
    }
    void display() {
        fill(50, 200, 255);
        noStroke();
        rectMode(CENTER);
        rect(x, y, w, h);
    }
    void move(int dir) {
        direction = dir;
    }
}

class Bullet {
    float x;
    float y;
    float r = 5;
    float speed = 8;
    Bullet(float x, float y) {
        this.x = x;
        this.y = y;
    }
    void update() {
        y -= speed;
    }
    void display() {
        fill(255, 200, 50);
        noStroke();
        ellipse(x, y, r*2, r*2);
    }
    boolean offscreen() {
        return y < -r;
    }
}

class Enemy {
    float x;
    float y;
    float w = 40;
    float h = 20;
    float speed = 1.5;
    static int dir = 1; // shared direction for all enemies
    Enemy(float x, float y) {
        this.x = x;
        this.y = y;
    }
    void update() {
        x += speed * dir;
        if (x < w/2 || x > width - w/2) {
            dir *= -1;
            y += h;
        }
    }
    void display() {
        fill(255, 50, 100);
        noStroke();
        rectMode(CENTER);
        rect(x, y, w, h);
    }
    boolean hitBy(Bullet b) {
        return b.x > x - w/2 && b.x < x + w/2 && b.y > y - h/2 && b.y < y + h/2;
    }
}
