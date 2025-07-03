import curses
import time

# Character representations
INVADER_CHAR = 'V'
PLAYER_CHAR = 'A'
BULLET_CHAR = '|'

MOVE_DELAY = 0.05  # seconds between frames
INVADER_STEP = 5    # frames between invader moves


def create_invaders(max_x, rows=3, cols=6, offset_y=1, spacing_x=3):
    invaders = []
    for r in range(rows):
        for c in range(cols):
            x = 1 + c * spacing_x
            y = offset_y + r
            if x < max_x - 1:
                invaders.append([y, x])
    return invaders


def draw(stdscr, invaders, player_x, bullet, score):
    stdscr.clear()
    for y, x in invaders:
        stdscr.addstr(y, x, INVADER_CHAR)
    if bullet:
        stdscr.addstr(bullet[0], bullet[1], BULLET_CHAR)
    max_y, _ = stdscr.getmaxyx()
    stdscr.addstr(max_y - 1, player_x, PLAYER_CHAR)
    stdscr.addstr(0, 0, f"Score: {score}")
    stdscr.refresh()


def game_loop(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    max_y, max_x = stdscr.getmaxyx()
    player_x = max_x // 2
    bullet = None
    invaders = create_invaders(max_x)
    direction = 1
    score = 0
    frame = 0

    while True:
        key = stdscr.getch()
        if key == curses.KEY_LEFT and player_x > 1:
            player_x -= 1
        elif key == curses.KEY_RIGHT and player_x < max_x - 2:
            player_x += 1
        elif key == ord(' '):
            if bullet is None:
                bullet = [max_y - 2, player_x]

        if frame % INVADER_STEP == 0:
            move_down = False
            for inv in invaders:
                inv[1] += direction
                if inv[1] <= 1 or inv[1] >= max_x - 2:
                    move_down = True
            if move_down:
                direction *= -1
                for inv in invaders:
                    inv[0] += 1
            if any(inv[0] >= max_y - 2 for inv in invaders):
                break

        if bullet:
            bullet[0] -= 1
            if bullet[0] <= 0:
                bullet = None
            else:
                for inv in invaders:
                    if inv[0] == bullet[0] and inv[1] == bullet[1]:
                        invaders.remove(inv)
                        bullet = None
                        score += 1
                        break
            if not invaders:
                break

        draw(stdscr, invaders, player_x, bullet, score)
        time.sleep(MOVE_DELAY)
        frame += 1

    stdscr.nodelay(False)
    message = 'YOU WIN!' if not invaders else 'GAME OVER'
    stdscr.addstr(max_y // 2, max_x // 2 - len(message) // 2, message)
    stdscr.addstr(max_y // 2 + 1, max_x // 2 - 6, f'Score: {score}')
    stdscr.addstr(max_y // 2 + 3, max_x // 2 - 10, 'Press any key to exit')
    stdscr.getch()


def main():
    curses.wrapper(game_loop)


if __name__ == '__main__':
    main()
