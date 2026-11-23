<template>
    <div flex flex-1 flex-col items-center>
        <section container class="mb-16 mt-24 sm:mb-32 sm:mt-36">
            <div flex class="flex-col px-0 sm:flex-row 2xl:px-24 xl:px-16">
                <div class="mb-4 mr-0 flex items-start justify-center md:mr-6 sm-mb-0 sm:mr-4 md-items-center">
                    <div class="i-custom:icon text-7xl md:text-[9.5rem] sm:text-9xl" />
                </div>
                <div class="text-center sm:text-start">
                    <h1 class="text-4xl sm:text-5xl" font-bold text="#2A9D8F">
                        Sandbox Science
                    </h1>
                    <h2 class="text-lg sm:text-2xl" mt-3 font-bold>
                        Unlock the mysteries of science through immersive and interactive simulations.
                    </h2>
                    <p mt-4 class="text-sm sm:text-base">
                        Explore Game of Life, Particle Life, and other captivating scientific simulations. Dive into hands-on
                        learning and discover complex concepts with interactive visual experiences.
                    </p>
                </div>
            </div>
        </section>
        <section container>
            <div grid grid-cols-1 gap-4 class="sm:grid-cols-3">
                <NuxtLink
                    to="/particle-life" bg="gray-900 hover:gray-800"
                    class="relative overflow-hidden border border-gray-800 rounded-lg p-6 pt-3 shadow-lg md:p-6 sm:p-5 md:pt-4 sm:pt-4"
                >
                    <div mb-2 flex items-center>
                        <span class="text-2xl md:text-3xl" mr-2 font-bold>⚛</span>
                        <h3 class="text-lg font-semibold md:text-xl">
                            Particle Life
                        </h3>
                    </div>
                    <p class="text-sm md:text-base">
                        Observe the fascinating interactions and emergent behaviors of particles in a dynamic and interactive environment.
                    </p>
                    <div class="absolute right-0 top-0 h-16 w-16">
                        <div class="absolute right-[-38px] top-[13px] w-[128px] rotate-45 transform bg-[#00b84d] bg-opacity-70 py-1 text-center text-sm text-white font-semibold shadow-lg">
                            BETA
                        </div>
                    </div>
                </NuxtLink>
                <NuxtLink
                    to="/game-of-life" bg="gray-900 hover:gray-800"
                    class="relative overflow-hidden border border-gray-800 rounded-lg p-6 pt-3 shadow-lg md:p-6 sm:p-5 md:pt-4 sm:pt-4"
                >
                    <div mb-2 flex items-center>
                        <span class="text-2xl md:text-3xl" mr-1 font-bold>🧬</span>
                        <h3 class="text-lg font-semibold md:text-xl">
                            Game Of Life
                        </h3>
                    </div>
                    <p class="text-sm md:text-base">
                        Explore the intriguing patterns and behaviors of cellular automata in this classic simulation by John Conway.
                    </p>
                    <div class="absolute right-0 top-0 h-16 w-16">
                        <div class="absolute right-[-38px] top-[13px] w-[128px] rotate-45 transform bg-[#e76f51] bg-opacity-70 py-1 text-center text-sm text-white font-semibold shadow-lg">
                            ALPHA
                        </div>
                    </div>
                </NuxtLink>
                <NuxtLink
                    to="/hash-life" bg="gray-900 hover:gray-800"
                    class="relative overflow-hidden border border-gray-800 rounded-lg p-6 pt-3 shadow-lg md:p-6 sm:p-5 md:pt-4 sm:pt-4"
                >
                    <div mb-2 flex items-center>
                        <span class="text-2xl md:text-3xl" mr-2 font-bold>🚀</span>
                        <h3 class="text-lg font-semibold md:text-xl">
                            Hash Life
                        </h3>
                    </div>
                    <p class="text-sm md:text-base">
                        Experience the optimized version of the Game of Life, enabling faster and more efficient simulation of complex patterns.
                    </p>
                    <div class="absolute right-0 top-0 h-16 w-16">
                        <div class="absolute right-[-38px] top-[13px] w-[128px] rotate-45 transform bg-[#5b2e48] bg-opacity-70 py-1 text-center text-sm text-white font-semibold shadow-lg">
                            WIP
                        </div>
                    </div>
                </NuxtLink>
            </div>
        </section>
        <section my-12 flex flex-1 flex-col justify-end>
            <div w-full flex>
                <NuxtLink to="https://discord.com/invite/z5yuzkFpCA" title="Discord" aria-label="Discord" target="_blank" mx-2 flex items-center py-0>
                    <button type="button" name="Discord" aria-label="Discord" text="zinc-3 hover:zinc-1" flex>
                        <span i-carbon-logo-discord text-5xl />
                    </button>
                </NuxtLink>
                <NuxtLink to="https://github.com/DicSo92/SandboxScience" title="Github" aria-label="Github" target="_blank" mx-2 flex items-center py-0>
                    <button type="button" name="Github" aria-label="Github" text="zinc-3 hover:zinc-1" flex>
                        <span i-carbon-logo-github text-5xl />
                    </button>
                </NuxtLink>
            </div>
        </section>
    </div>
</template>

<script setup lang="ts">
definePageMeta({
    layout: 'life',
})
</script>

<style scoped lang="scss">

</style>
