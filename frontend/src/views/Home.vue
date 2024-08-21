<template>
  <div>
    <Navbar/>
    <h1>Welcome to Glamify</h1>
    <ClothingList/>
  </div>
</template>

<script>
import Navbar from "@/components/AppNavbar.vue";
import ClothingList from "@/components/ClothingList.vue";

export default {
  name: "Home",
  components: {
    Navbar,
    ClothingList
  }
};
</script>
