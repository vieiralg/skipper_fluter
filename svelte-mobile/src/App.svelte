<script>
  const gameUrl =
    import.meta.env.VITE_GAME_URL || `http://${window.location.hostname}:8080/`;
</script>

<main class="page-shell">
  <section class="game-shell" aria-label="Skipper em frame 16-bit">
    <div class="arcade-header">
      <span class="status-lights" aria-hidden="true">
        <span></span>
        <span></span>
        <span></span>
      </span>
      <span class="game-title">Skipper</span>
      <span class="tag">16-bit mobile frame</span>
    </div>

    <div class="game-frame">
      <iframe
        title="Skipper - jogo Flutter Web"
        src={gameUrl}
        allow="fullscreen; autoplay; gamepad"
      ></iframe>
    </div>
  </section>
</main>
