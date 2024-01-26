import Draw from 'draw-on-canvas'

export default {
    mounted() {
        console.log("得到draw", Draw)

        this.draw = new Draw(this.el, 384, 384, {
            backgroundColor: "black",
            strokeColor: "white",
            strokeWeight: 10
        })

        this.handleEvent("reset", () => {
            this.draw.reset()
        })

        this.handleEvent("predict", () => {
            this.pushEvent("image", this.draw.canvas.toDataURL('image/png'))
        })
    }
}
