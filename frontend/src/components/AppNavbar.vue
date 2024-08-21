<template>
  <nav>
    <router-link to="/">Home</router-link>
    <router-link to="/profile">Profile</router-link>
    <router-link to="/login">Login</router-link>
  </nav>
</template>

<script>
export default {
  name: "AppNavbar", // Changed the name to be multi-word
};
</script>

<style scoped>
nav {
  display: flex;
  justify-content: space-around;
  padding: 1rem;
  background-color: #333;
  color: white;
}

router-link {
  color: white;
  text-decoration: none;
}

router-link:hover {
  text-decoration: underline;
}
</style>
