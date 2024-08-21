<template>
  <div id="app">
    <!-- Updated component names -->
    <AppNavbar/>

    <main>
      <router-view/>
    </main>

    <AppFooter/>
  </div>
</template>

<script>
// Updated import statements
import AppNavbar from "@/components/AppNavbar.vue";
import AppFooter from "@/components/AppFooter.vue";

export default {
  name: "App",
  components: {
    AppNavbar,
    AppFooter,
  },
};
</script>

<style>
/* Global styles for the entire application */

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 0;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

main {
  flex: 1; /* Ensures the main content area expands to fill the space between navbar and footer */
  padding: 20px;
}

/* Simple styling for the Navbar */
nav {
  background-color: #34495e;
  padding: 10px;
}

/* Footer styling */
footer {
  background-color: #34495e;
  color: white;
  padding: 10px;
  text-align: center;
}
</style>
