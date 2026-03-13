if (!requireNamespace("hyperSpec", quietly = TRUE)) {
    install.packages("hyperSpec", repos = "https://cloud.r-project.org")
}

library(hyperSpec)

data(laser)

spectra <- laser$spc
available_pixels <- nrow(spectra)
grid_size <- floor(sqrt(available_pixels))
n_pixels <- grid_size^2

if (n_pixels == 0) {
    stop("Not enough spectra to build a 2D grid.")
}

if (n_pixels < available_pixels) {
    message(
        "Using the first ", n_pixels, " spectra as a ",
        grid_size, "x", grid_size, " grid."
    )
}

adjacency <- matrix(0, nrow = n_pixels, ncol = n_pixels)

for (i in seq_len(n_pixels)) {
    if (i %% grid_size != 0) {
        adjacency[i, i + 1] <- 1
        adjacency[i + 1, i] <- 1
    }

    if (i + grid_size <= n_pixels) {
        adjacency[i, i + grid_size] <- 1
        adjacency[i + grid_size, i] <- 1
    }
}

degree_matrix <- diag(rowSums(adjacency))
laplacian <- degree_matrix - adjacency

cat("Adjacency matrix (top-left 10x10 block):\n")
print(adjacency[1:10, 1:10])

cat("\nGraph Laplacian (top-left 10x10 block):\n")
print(laplacian[1:10, 1:10])

par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))

image(
    1:n_pixels, 1:n_pixels, adjacency[n_pixels:1, ],
    col = c("white", "steelblue"),
    xlab = "Pixel index",
    ylab = "Pixel index",
    main = sprintf("Adjacency Matrix (%dx%d Grid)", grid_size, grid_size)
)

image(
    1:n_pixels, 1:n_pixels, laplacian[n_pixels:1, ],
    col = hcl.colors(12, "Blue-Red 3", rev = TRUE),
    xlab = "Pixel index",
    ylab = "Pixel index",
    main = sprintf("Graph Laplacian (%dx%d Grid)", grid_size, grid_size)
)
